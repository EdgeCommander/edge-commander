defmodule EdgeCommanderWeb.SharingController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Sharing.Member
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  alias EdgeCommander.Accounts.User
  import Ecto.Query, warn: false
  import EdgeCommander.Sharing, only: [list_sharing: 0, get_member!: 1]
  import EdgeCommander.Accounts, only: [email_exist: 1, get_user!: 1]
  require Logger

  def create(conn, params) do
    is_valid_email = Regex.match?(~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, params["sharee_email"])
    validate_email(is_valid_email, conn, params)
  end

  def get_all_members(conn, params)  do
    [column, order] = params["sort"] |> String.split("|")
    query = "select * from sharing as s #{add_sorting(column, order)}"
    sharing = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map sharing.columns, &(String.to_atom(&1))
    roles = Enum.map sharing.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = sharing.num_rows
    d_length = String.to_integer(params["per_page"])
    display_length = if d_length < 0, do: total_records, else: d_length
    display_start = if String.to_integer(params["page"]) <= 1, do: 0, else: (String.to_integer(params["page"]) - 1) * display_length + 1
    index_e = ((String.to_integer(params["page"]) - 1) * display_length) + display_length
    index_end = if index_e > total_records, do: total_records - 1, else: index_e
    last_page = Float.round(total_records / (display_length / 1))

    data =
      case total_records <= 0 do
        true -> []
        _ ->
          Enum.reduce(display_start..index_end, [], fn i, acc ->
              share = Enum.at(roles, i)
              sharee_record = get_user_details(share[:sharee_id])
              sharer_record = get_user_details(share[:sharee_id])
              sh = %{
              id: share[:id],
              sharee_email: sharee_record.email,
              sharee_name: sharee_record.full_name,
              sharer_email: sharer_record.email,
              sharer_name: sharer_record.full_name,
              rights: share[:rights] |> get_rights_text,
              created_at: share[:inserted_at] |> Util.shift_zone()
            }
            acc ++ [sh]
          end)
      end

      records = %{
        data: (if total_records < 1, do: [], else: data),
        total: total_records,
        per_page: display_length,
        from: display_start,
        to: index_end,
        current_page: String.to_integer(params["page"]),
        last_page: last_page,
        next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/members?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
        prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/members?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
      }
      json(conn, records)
  end

  defp get_rights_text(1),  do: "Full Rights"
  defp get_rights_text(_),  do: "Read-Only"

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("sharee_email", order), do: "ORDER BY sharee_id #{order}"
  defp add_sorting("sharer_email", order), do: "ORDER BY sharer_id #{order}"
  defp add_sorting("rights", order), do: "ORDER BY rights #{order}"
  defp add_sorting("created_at", order), do: "ORDER BY created_at #{order}"

  def delete(conn, %{"id" => id} = _params) do
    member_records = get_member!(id)
    user_id = member_records.sharee_id
    member_records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Sharing.Member{}} ->
        EdgeCommanderWeb.UsersController.delete(conn, %{"id" => user_id})
        conn
        |> put_status(200)
        |> json("")
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  defp validate_email(false, conn, _params) do
    conn
    |> put_status(400)
    |> json(%{ errors: ["Sorry, please enter valid email address."]})
  end
  defp validate_email(true, conn, params) do
    sharee_email = params["sharee_email"]
    user_exist = sharee_email |> email_exist
    ensure_user_exist(user_exist, conn, params)
  end

  defp ensure_user_exist(nil, conn, params)  do
    password = Util.string_generator(6) |> String.downcase
    user_params = Map.merge(params, %{"password" => password})
    user = create_user(user_params)
    sharee_id = user.id
    sharing_params = %{
      "sharer_id" => user_params["user_id"],
      "sharee_id" => sharee_id,
      "rights" => user_params["rights"]
    }
    changeset = Member.changeset(%Member{}, sharing_params)
    case Repo.insert(changeset) do
      {:ok, member} ->
        sharer_record = get_user_details(member.sharer_id)
        notification_data = %{
          sharee_email: user.email,
          sharee_password: password,
          sharer_name: sharer_record.full_name,
          sharer_email: sharer_record.email
        }
        Logger.info "Notification email has been sent."
        EdgeCommander.EcMailer.notification_email_on_share(notification_data)
        conn
        |> put_status(:created)
        |> json(%{
          "sharer_id" => member.sharer_id,
          "sharee_id" => member.sharee_id,
          "rights" => member.rights
        })
      {:error, changeset} -> Logger.error changeset
     end
  end
  defp ensure_user_exist(_user_exist, conn, _params) do
    conn
    |> put_status(400)
    |> json(%{ errors: ["Sorry, user exist first this user must delete their account."]})
  end

  defp create_user(params) do
    email = String.downcase(params["sharee_email"])
    api_id = UUID.uuid4(:hex) |> String.slice(0..7)
    api_key = UUID.uuid4(:hex)
    username = String.split(params["sharee_email"], "@") |> List.first
    password = params["password"]
    user_params = %{
      "email" => email,
      "password" => password,
      "firstname" => username,
      "api_key" => api_key,
      "api_id" => api_id,
      "username" => username
    }
    changeset = User.changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} -> user
      {:error, changeset} -> Logger.error changeset
    end
  end
  def get_user_details(user_id) do
    user_details = user_id |> get_user!
    fname = user_details |> Map.get(:firstname) |> is_empty
    lname = user_details |> Map.get(:lastname) |> is_empty
    full_name = fname <> " " <> lname
    email = user_details |> Map.get(:email)
    %{
      full_name: full_name,
      email: email
    }
  end
  defp is_empty(nil), do: ""
  defp is_empty(name), do: name
end
