defmodule EdgeCommanderWeb.ThreeController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.ThreeScraper.ThreeUsers
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Accounts, only: [current_user: 1]
  import ThreeScraper.Scraper, only: [single_start_scraper: 1, update_bill_days: 2]

  def create(conn, params) do
    changeset = ThreeUsers.changeset(%ThreeUsers{}, params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        %EdgeCommander.ThreeScraper.ThreeUsers{
          password: password,
          user_id: user_id,
          bill_day: bill_day
        } = user

        username = params["username"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Three: username <span>#{username}</span> was created.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        spawn fn -> single_start_scraper(user.id) end

        conn
        |> put_status(:created)
        |> json(%{
          "username" => username,
          "password" => password,
          "user_id" => user_id,
          "bill_day" => bill_day
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def get_all_three_accounts(conn, params)  do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from three_users as us Where lower(us.username) like lower('%#{search}%') #{add_sorting(column, order)}"
    users = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map users.columns, &(String.to_atom(&1))
    roles = Enum.map users.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = users.num_rows
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
              user = Enum.at(roles, i)
              ru = %{
                id: user[:id],
                username: user[:username],
                password: user[:password],
                user_id: user[:user_id],
                bill_day: user[:bill_day],
                created_at: user[:inserted_at] |> Util.shift_zone()
            }
            acc ++ [ru]
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
      next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/three_accounts?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
      prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/three_accounts?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
    }
    json(conn, records)
  end

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("username", order), do: "ORDER BY username #{order}"
  defp add_sorting("password", order), do: "ORDER BY password #{order}"
  defp add_sorting("bill_day", order), do: "ORDER BY bill_day #{order}"
  defp add_sorting("created_at", order), do: "ORDER BY created_at #{order}"

  def update(conn, %{"id" => id} = params) do
    ThreeUsers.get_three_account!(id)
    |> ThreeUsers.changeset(params)
    |> Repo.update
    |> case do
      {:ok, user} ->
        %EdgeCommander.ThreeScraper.ThreeUsers{
          password: password,
          bill_day: bill_day,
          updated_at: updated_at
        } = user

        username = params["username"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Three: username <span>#{username}</span> was updated.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        update_bill_days(id, bill_day)

        spawn fn -> single_start_scraper(user.id) end

        conn
        |> put_status(:created)
        |> json(%{
          "username" => username,
          "password" => password,
          "bill_day" => bill_day,
          "updated_at" => updated_at
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })   
    end
  end

  def delete(conn, %{"id" => id} = _params) do
    records = ThreeUsers.get_three_account!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.ThreeScraper.ThreeUsers{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        username = records.username
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Three: username <span>#{username}</span> was deleted.",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

end
