defmodule EdgeCommanderWeb.CommandsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Commands.Rule
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import Ecto.Query, warn: false
  import EdgeCommander.Commands, only: [list_rules: 0, get_rule!: 1]
  use PhoenixSwagger

  swagger_path :get_all_rules do
    get "/v1/rules"
    description "Returns rules list"
    summary "Returns all rules"
    parameters do
      api_key :query, :string, "", required: true, default: "ea3f489a45c98eab5cc22e38db1071e8"
      api_id :query, :string, "", required: true, default: "2091d756"
    end
    tag "rules"
    response 200, "Success"
  end

  swagger_path :delete do
    delete "/v1/rules/{id}"
    summary "Delete rule by ID"
    parameters do
      id :path, :string, "Rule id to delete", required: true
      api_key :query, :string, "", required: true, default: "ea3f489a45c98eab5cc22e38db1071e8"
      api_id :query, :string, "", required: true, default: "2091d756"
    end
    tag "rules"
    response 200, "Success"
  end

  def create(conn, params) do
    changeset = Rule.changeset(%Rule{}, params)
    case Repo.insert(changeset) do
      {:ok, rule} ->
        %EdgeCommander.Commands.Rule{
          rule_name: rule_name,
          active: active,
          category: category,
          recipients: recipients,
          inserted_at: created_at
        } = rule

        conn
        |> put_status(:created)
        |> json(%{
          "rule_name" => rule_name,
          "active" => active,
          "category" => category,
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
          recipients: rule.recipients,
          created_at: rule.inserted_at
        }
      end)
    conn
    |> put_status(200)
    |> json(rules)
  end

  def update(conn, %{"id" => id} = params) do
    get_rule!(id)
    |> Rule.changeset(params)
    |> Repo.update
    |> case do
      {:ok, rule} ->
        %EdgeCommander.Commands.Rule{
          rule_name: rule_name,
          inserted_at: inserted_at
        } = rule

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

  def delete(conn, %{"id" => id} = _params) do
    get_rule!(id)
    |> Repo.delete
    |> case do
      {:ok, %EdgeCommander.Commands.Rule{}} ->
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
end
