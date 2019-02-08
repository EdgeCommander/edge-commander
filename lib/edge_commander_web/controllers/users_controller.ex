defmodule EdgeCommanderWeb.UsersController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Repo
  alias EdgeCommander.Accounts.User
  alias EdgeCommander.Sharing.Member
  alias EdgeCommanderWeb.SessionController
  alias EdgeCommander.Util
  require Logger
  import EdgeCommander.Accounts, only: [get_user!: 1, email_exist: 1, get_user_by_token: 1, current_user: 1]
  import EdgeCommander.Sharing, only: [user_by_email: 1]
  import Gravatar

  def get_porfile(conn, _params) do
    current_user = current_user(conn)
    current_user_id = current_user.id

    user_record = get_user!(current_user_id)
    firstname = user_record.firstname
    lastname = user_record.lastname
    email = user_record.email
    password = user_record.password
    id = user_record.id
    api_key = user_record.api_key
    api_id = user_record.api_id
    username = user_record.username
    gravatar_url = current_user.email |> gravatar_url(secure: true)
    csrf_token = get_csrf_token()

    conn
    |> put_status(:created)
    |> json(%{
      "firstname" => firstname,
      "lastname" => lastname,
      "email" => email,
      "password" => password,
      "id" => id,
      "api_key" => api_key,
      "api_id" => api_id,
      "username" => username,
      "gravatar_url" => gravatar_url,
      "csrf_token" => csrf_token
    })

  end

  def sign_up(conn, params) do
    email = String.downcase(params["email"])
    params = %{
      "_csrf_token" => params["_csrf_token"],
      "email" => email,
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

          user_by_email(email)
          |> Enum.map(fn(data) ->
            update_sharing_record(data, user)
          end)

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
      {:ok, _user} ->
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
          {:ok, _user} ->
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

        user_email = params["email"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Account details of <span>#{user_email}</span> was updated.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

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
    utc_datetime = Calendar.DateTime.now_utc |> DateTime.truncate(:second)
    {:ok, Map.merge(params, %{"username" => username, "last_signed_in" => utc_datetime})}
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

  defp update_sharing_record(nil, _user), do: :noop
  defp update_sharing_record(member_details, user)  do
    sharing_params = %{"member_id" => user.id}
    member_details
    |> Member.changeset(sharing_params)
    |> Repo.update
  end
end
