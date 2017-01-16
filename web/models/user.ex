defmodule LookupPhoenix.User do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query
  alias LookupPhoenix.Repo

  schema "users" do
      field :name, :string
      field :username, :string
      field :email, :string
      field :password, :string

      timestamps()
    end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username email), [] )
    |> validate_length(:username, min: 1, max: 20)
  end

  end
