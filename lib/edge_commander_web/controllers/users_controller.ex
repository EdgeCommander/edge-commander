defmodule EdgeCommanderWeb.UsersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  alias EdgeCommander.Accounts.User
  alias EdgeCommanderWeb.SessionController
  alias EdgeCommander.Util
  require Logger
  import EdgeCommander.Accounts, only: [get_user!: 1, email_exist: 1, get_user_by_token: 1]

  def sign_up(conn, params) do
    params = %{
      "_csrf_token" => params["_csrf_token"],
      "email" => String.downcase(params["email"]),
      "firstname" => params["firstname"],
      "lastname" => params["lastname"],
      "password" => params["password"]
    }
    with  {:ok, updated_params} <- merge_last_signed_in(params),
          {:ok, changeset} <- changeset_is_fine(updated_params)
    do
      case Repo.insert(changeset) do
        {:ok, user} ->
          Logger.info "[POST /create_user] [#{user.email}] [#{user.last_signed_in}]"
          conn
          |> put_flash(:info, "Your account has been created.")
          |> SessionController.create(params)
          |> redirect(to: "/sims")
        {:error, changeset} ->
          errors = Util.parse_changeset(changeset)
          traverse_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
          conn
          |> put_flash(:error, traverse_errors |> List.first)
          |> redirect(to: "/users/sign_up")
      end
    else
      {:error, errors} ->
        error = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_flash(:error, error |> List.first)
        |> redirect(to: "/users/sign_up")
    end
  end

  def forgot_password(conn, params) do
    email = params["email"]
    user = email_exist(email)
    token_expire = Timex.shift(Timex.now, minutes: 15)
    reset_token = Util.string_generator(20)
    params = Map.merge(params, %{"reset_token" => reset_token, "token_expire" => token_expire})

    if user != nil do
      user
      |> User.changeset(params)
      |> Repo.update
      |> case do
      {:ok, user} ->
          EdgeCommander.EcMailer.forgot_password(email, reset_token)
          conn
          |> put_flash(:info, "Password reset link has been sent to your email address.")
          |> redirect(to: "/users/forgot_password")

        {:error, errors} ->
        conn
        |> put_flash(:error, errors)
      end
      else
        conn
        |> put_flash(:error, "Email does not exist.")
        |> redirect(to: "/users/forgot_password")
    end
  end

  def reset_password(conn, %{"token" => token} = params) do
    user = get_user_by_token(token)
    token_expire = user.token_expire
    current_date = Timex.now

    diff = Timex.diff(token_expire,current_date, :minutes)

    if diff <= 0 do
       conn
        |> put_flash(:error, "Reset token has been expired.")
        |> redirect(to: "/users/reset_password/"<> token)
      else
        user
        |> User.changeset(params)
        |> Repo.update
        |> case do
          {:ok, user} ->
            conn
            |> redirect(to: "/users/reset_password_success")
          {:error, errors} ->
            conn
            |> put_flash(:error, errors)
            |> redirect(to: "/users/reset_password/"<> token)
        end
    end
  end

  def update_profile(conn, %{"id" => id} = params) do
    params = %{
      "email" => String.downcase(params["email"]),
      "firstname" => params["firstname"],
      "id" => params["id"],
      "lastname" => params["lastname"],
      "password" => params["password"]
    }
    get_user!(id)
    |> User.changeset(params)
    |> Repo.update
    |> case do
      {:ok, user} ->
        %User{
          firstname: firstname,
          lastname: lastname,
          email: email,
          password: password,
          id: id
        } = user

        conn
        |> put_status(:created)
        |> json(%{
          "firstname" => firstname,
          "lastname" => lastname,
          "email" => email,
          "password" => password,
          "id" => id
        })

      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
      end
  end

  defp merge_last_signed_in(params) do
    username = String.split(params["email"], "@") |> List.first
    {:ok, Map.merge(params, %{"username" => username, "last_signed_in" => Ecto.DateTime.utc})}
  end

  defp changeset_is_fine(params) do
    api_id = UUID.uuid4(:hex) |> String.slice(0..7)
    api_key = UUID.uuid4(:hex)
    updated_params = Map.merge(params, %{"api_key" => api_key, "api_id" => api_id})
    case changeset = User.changeset(%User{}, updated_params) do
      %Ecto.Changeset{valid?: true} ->
        {:ok, changeset}
      %Ecto.Changeset{valid?: false} ->
        {:error, Util.parse_changeset(changeset)}
    end
  end
end
