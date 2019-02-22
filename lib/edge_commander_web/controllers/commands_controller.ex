defmodule EdgeCommanderWeb.CommandsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Commands.Rule
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Commands, only: [list_rules: 0, get_rule!: 1]
  import EdgeCommander.Accounts, only: [current_user: 1]
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Rule: swagger_schema do
        title "Rule"
        description "A rule of the application"
        properties do
          id :integer, ""
          rule_name :string, "", required: true
          recipients :string, "", required: true, example: "test@user.com, who@am.io"
          category :string, "", required: true, enum: ["usage_command"]
          active :boolean, "", required: true, default: false
        end
      end
    }
  end

  swagger_path :get_all_rules do
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

  def get_all_rules(conn, _params)  do
    rules = 
      list_rules()
      |> Enum.map(fn(rule) ->
        %{
          id: rule.id,
          rule_name: rule.rule_name,
          active: rule.active,
          category: rule.category,
          variable: rule.variable,
          value: rule.value,
          recipients: rule.recipients,
          created_at: rule.inserted_at |> Util.shift_zone()
        }
      end)
    conn
    |> put_status(200)
    |> json(%{
        rules: rules
      })
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
        current_user = current_user(conn)
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
end
