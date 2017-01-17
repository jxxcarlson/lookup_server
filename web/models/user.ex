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
      field :password_hash, :string
      field :registration_code, :string

      timestamps()
    end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username email password registration_code), [] )
    |> validate_length(:username, min: 1, max: 20)
    |> validate_inclusion(:registration_code, ["ladidah", "uahs"])
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
    |> erase_password()
  end

  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  def erase_password(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
          put_change(changeset, :password, "")
        _ ->
          changeset
      end
    end

  end
