defmodule Delivery.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Delivery.Order

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_params [:age, :address, :zipcode, :cpf, :email, :password, :name]

  @update_params [:age, :address, :zipcode, :cpf, :email, :name]

  @derive {Jason.Encoder, only: [:id, :name, :email, :age, :cpf, :address]}

  schema "users" do
    field :age, :integer
    field :address, :string
    field :zipcode, :string
    field :cpf, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :name, :string

    has_many :orders, Order

    timestamps()
  end

  def build(changeset), do: apply_action(changeset, :create)

  # def build(params) do
  #   |> changeset()
  #   |> apply_action(:insert)
  # end

  def changeset(params) do
    fields = @required_params

    %__MODULE__{}
    |> changes(params, @required_params = fields)
  end

  def changeset(changeset \\ %__MODULE__{}, params) do
    fields = @update_params

    changeset
    |> changes(params, fields)
  end

  defp changes(changeset, params, fields) do
    changeset
    |> cast(params, fields)
    |> validate_required(fields)
    |> validate_length(:password, min: 6)
    |> validate_length(:zipcode, is: 8)
    |> validate_length(:cpf, is: 11)
    |> validate_number(:age, greater_than_or_equal_to: 18)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint([:cpf])
    |> unique_constraint([:email])
    |> put_password_hash()
  end

  defp put_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Pbkdf2.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset
end
