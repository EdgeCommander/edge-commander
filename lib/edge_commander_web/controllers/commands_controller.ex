defmodule EdgeCommanderWeb.CommandsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Commands.Rule
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Commands, only: [get_rule!: 1, get_rules_by_user: 1]
  import EdgeCommander.Accounts, only: [current_user: 1, get_current_resource: 1]
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Rule: swagger_schema do
        title "Rule"
        description "A rule module of the application"
        properties do
          active :boolean, "", required: true, default: false
          category :string, "", required: true
          created_at :string, "", required: true
          id :integer, ""
          recipients :array, "", required: true, example: "['test@user.com', 'who@am.io']"
          rule_name :string, "", required: true
          value :integer, "", required: true
          variable :string, "", required: true, example: "greater_than"
        end
      end
    }
  end

  swagger_path :get_all_rules_by_users do
    get "/v1/rules"
    description "Returns rules list"
    summary "Returns all rules"
    parameters do
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "rules"
    response 200, "Success"
  end

  swagger_path :delete_rule do
    delete "/v1/rules/{id}"
    summary "Delete rule by ID"
    parameters do
      id :path, :string, "Rule id to delete", required: true
      api_id :query, :string, "", required: true
      api_key :query, :string, "", required: true
    end
    tag "rules"
    response 200, "Success"
  end

  def create(conn, params) do
    changeset = Rule.changeset(%Rule{}, params)
    case Repo.insert(changeset) do
      {:ok, rule} ->
        %EdgeCommander.Commands.Rule{
          active: active,
          category: category,
          variable: variable,
          value: value,
          recipients: recipients,
          inserted_at: created_at
        } = rule

        rule_name = params["rule_name"]
        current_user = current_user(conn)
        logs_params = %{
          "event" => "Rule: <span>#{rule_name}</span> was created in <span>commands</span>",
          "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "rule_name" => rule_name,
          "active" => active,
          "category" => category,
          "variable" => variable,
          "value" => value,
          "recipients" => recipients,
          "created_at" => created_at
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end

  def get_all_rules_by_users(conn, params) do
    user_id = Util.get_user_id(conn, params)
    rules =
      get_rules_by_user(user_id)
      |> Enum.map(fn(rule) ->
        %{
          "id" => rule.id,
          "rule_name" => rule.rule_name,
          "active" => rule.active,
          "category" => rule.category,
          "variable" => rule.variable,
          "value" => rule.value,
          "recipients" => rule.recipients,
          "created_at" => rule.inserted_at
        }
      end)

    conn
    |> put_status(200)
    |> json(%{
        rules: rules
      })
  end

  def get_all_rules(conn, params)  do
    [column, order] = params["sort"] |> String.split("|")
    search = if params["search"] in ["", nil], do: "", else: params["search"]
    query = "select * from rules as r Where lower(r.rule_name) like lower('%#{search}%') #{add_sorting(column, order)}"
    rules = Ecto.Adapters.SQL.query!(Repo, query, [])
    cols = Enum.map rules.columns, &(String.to_atom(&1))
    roles = Enum.map rules.rows, fn(row) ->
      Enum.zip(cols, row)
    end

    total_records = rules.num_rows
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
              rule = Enum.at(roles, i)
              ru = %{
              id: rule[:id],
              rule_name: rule[:rule_name],
              active: rule[:active],
              category: rule[:category],
              variable: rule[:variable],
              value: rule[:value],
              recipients: rule[:recipients],
              created_at: rule[:inserted_at] |> Util.shift_zone()
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
        next_page_url: (if String.to_integer(params["page"]) == last_page, do: "", else: "/rules/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) + 1}"),
        prev_page_url: (if String.to_integer(params["page"]) < 1, do: "", else: "/rules/data?sort=#{params["sort"]}&per_page=#{display_length}&page=#{String.to_integer(params["page"]) - 1}")
      }
      json(conn, records)
  end

  def update(conn, %{"id" => id} = params) do
    get_rule!(id)
    |> Rule.changeset(params)
    |> Repo.update
    |> case do
      {:ok, rule} ->
        %EdgeCommander.Commands.Rule{
          inserted_at: inserted_at
        } = rule

        rule_name = params["rule_name"]
        current_user = current_user(conn)
        logs_params = %{
        "event" => "Rule: <span>#{rule_name}</span> was updated in <span>commands</span>",
        "user_id" => current_user.id
        }
        Util.create_log(conn, logs_params)

        conn
        |> put_status(:created)
        |> json(%{
          "rule_name" => rule_name,
          "created_at" => inserted_at
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })   
    end
  end

  def delete_rule(conn, %{"id" => id} = _params) do
    current_user = get_current_resource(conn)
    records = get_rule!(id)
    records
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Commands.Rule{}} ->
        conn
        |> put_status(200)
        |> json(%{
          deleted: true
        })
        rule_name = records.rule_name
        logs_params = %{
          "event" => "Rule: <span>#{rule_name}</span> was deleted in <span>commands</span>",
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

  defp add_sorting("id", order), do: "ORDER BY id #{order}"
  defp add_sorting("rule_name", order), do: "ORDER BY rule_name #{order}"
  defp add_sorting("active", order), do: "ORDER BY active #{order}"
  defp add_sorting("category", order), do: "ORDER BY category #{order}"
  defp add_sorting("variable", order), do: "ORDER BY variable #{order}"
  defp add_sorting("value", order), do: "ORDER BY value #{order}"
  defp add_sorting("recipients", order), do: "ORDER BY recipients #{order}"
  defp add_sorting("created_at", order), do: "ORDER BY created_at #{order}"

end
