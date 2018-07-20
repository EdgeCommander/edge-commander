defmodule EdgeCommander.Commands.Rule do
  use Ecto.Schema
  import Ecto.Changeset
  alias EdgeCommander.Commands.Rule

  @valid_email_string ~r/^([\w+-.%]+@[\w-.]+\.[A-Za-z]{2,4},?)+$/

  schema "rules" do
    belongs_to :user, EdgeCommander.Accounts.User

    field :active, :boolean, default: true
    field :category, :string
    field :recipients, {:array, :string}
    field :rule_name, :string

    timestamps()
  end

  defp validate_recipients(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{recipients: recipients}} ->
        recipients
        |> Enum.join(",")
        |> validate_emails_string(changeset)
        # changeset
        # put_change(changeset, :recipients, String.split(recipients, ","))
      _ ->
        changeset
    end
  end

  defp validate_emails_string(recipients, changeset) do
    case Regex.match?(@valid_email_string, recipients) do
      true -> changeset
      false ->
        add_error(changeset, :recipients, "Please add valid emails as 'foo@bar.com,bar@foo.com'")
    end
  end

  @doc false
  def changeset(%Rule{} = rule, attrs) do
    rule
    |> cast(attrs, [:rule_name, :category, :recipients, :active, :user_id])
    |> validate_recipients()
    |> validate_required(:rule_name, [message: "Rule Name cannot be empty."])
    |> validate_required(:category, [message: "Category cannot be empty."])
    |> validate_required(:recipients, [message: "Recipients cannot be empty."])
    |> validate_length(:rule_name, [min: 3, message: "Rule Name should be at least 2 character(s)."])
  end
end
