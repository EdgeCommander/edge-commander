defmodule EdgeCommanderWeb.SharingController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Sharing.Member
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Sharing, only: [list_sharing: 1, get_member!: 1, already_sharing: 2]
  import EdgeCommander.Accounts, only: [current_user: 1, email_exist: 1, get_user!: 1]

  def create(conn, params) do
    token = Util.string_generator(30)
    member_id = params["member_email"] |> email_exist |> get_member_id
    account_of_id = params["account_of_id"]
    member_email = params["member_email"]

    params = %{
      "user_id" => params["user_id"],
      "member_id" => member_id,
      "role" => params["role"],
      "member_email" => member_email,
      "account_of_id" => account_of_id,
      "token" => token
    }

    account_of_id = ensure_account_id(account_of_id)

    if (member_id == account_of_id) == false do
        already_sharing = already_sharing(member_email, account_of_id)
        if already_sharing == nil  do
            changeset = Member.changeset(%Member{}, params)
            case Repo.insert(changeset) do
              {:ok, member} ->
                %EdgeCommander.Sharing.Member{
                  user_id: user_id,
                  member_id: member_id,
                  role: role,
                  member_email: member_email,
                  account_of_id: account_of_id,
                  token: token
                } = member

                share_account = params["account_of_id"] |> get_user!
                user_info =  share_account.firstname <> " " <> share_account.lastname <> " (" <> share_account.email <> ")"
                EdgeCommander.EcMailer.signup_email_on_share(member_email, token, user_info)

                conn
                |> put_status(:created)
                |> json(%{
                  "user_id" => user_id,
                  "member_id" => member_id,
                  "role" => role,
                  "member_email" => member_email,
                  "account_of_id" => account_of_id,
                  "token" => token
                })
              {:error, changeset} ->
                errors = Util.parse_changeset(changeset)
                traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
                conn
                |> put_status(400)
                |> json(%{ errors: traversed_errors })
            end
          else
          conn
          |> put_status(400)
          |> json(%{ errors: ["Rights have been already given to that email address."]})
        end
      else
        conn
        |> put_status(400)
        |> json(%{ errors: ["Sorry you can not be given to own rights itself."]})
    end
  end

  def get_all_members(conn, params)  do
    current_user_id = Util.get_user_id(conn, params)
    members = 
      list_sharing(current_user_id)
      |> Enum.map(fn(member) ->

        if member.member_id != 0 do
            mem_details = member.member_id |> get_user_details
            member_name = mem_details.full_name
          else
            member_name = "Pending...."
        end

        share_by_details = member.user_id |> get_user_details
        share_by_name = share_by_details.full_name
        share_by_email = share_by_details.email

        account_of_details = member.account_of_id |> get_user_details
        account_of_name = account_of_details.full_name
        account_of_email = account_of_details.email

        %{
          id: member.id,
          user_id: member.user_id,
          share_by_name: share_by_name,
          share_by_email: share_by_email,
          member_id: member.member_id,
          member_name: member_name,
          member_email: member.member_email,
          account_of_name: account_of_name,
          account_of_email: account_of_email,
          role: member.role,
          created_at: member.inserted_at |> Util.shift_zone()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        "members": members
      })
  end

  def get_user_details(user_id) do
    user_details = user_id |> get_user!
    fname = user_details |> Map.get(:firstname)
    lname = user_details |> Map.get(:lastname)
    full_name = fname <> " " <> lname
    email = user_details |> Map.get(:email)
    %{
      full_name: full_name,
      email: email
    }
  end

  def delete(conn, %{"id" => id} = _params) do
    get_member!(id)
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Sharing.Member{}} ->
        conn
        |> put_status(200)
        |> json(%{
          "deleted": true
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  defp get_member_id(nil), do: 0
  defp get_member_id(member_details)  do
      member_details.id
  end

  defp ensure_account_id(""), do: -1
  defp ensure_account_id(account_id) do
    {account_of_id, ""} = Integer.parse(account_id)
    account_of_id
  end
end
