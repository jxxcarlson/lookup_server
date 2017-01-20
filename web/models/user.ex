defmodule LookupPhoenix.User do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query

  alias LookupPhoenix.Repo
  alias LookupPhoenix.Tag
  alias LookupPhoenix.User


  schema "users" do
      field :name, :string
      field :username, :string
      field :email, :string
      field :password, :string
      field :password_hash, :string
      field :registration_code, :string
      field :tags, {:array, :string }
      field :read_only, :boolean

      timestamps()
    end

  def running_changeset(model, params \\ :empty) do
      model
      |> cast(params, ~w(tags read_only), [] )
    end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username email password registration_code), [] )
    |> validate_length(:username, min: 1, max: 20)
    |> validate_inclusion(:registration_code, ["student", "pukool5", "uahs"])
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
    |> erase_password()
    # |> set_read_only(false)
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

  def set_read_only(changeset, value) do
        case changeset do
          %Ecto.Changeset{valid?: true, changes: %{read_only: value}} ->
            put_change(changeset, :read_only, value)
          _ ->
            changeset
        end
    end

  def update_tags(user_id) do
      user = Repo.get!(User, user_id)
      tags = Tag.get_all_user_tags(user_id) |> Enum.sort
      params = %{"tags" => tags}
      changeset = User.running_changeset(user, params)
      Repo.update(changeset)
  end

  def initialize_metadata(user) do
        params = %{"tags" => [], "read_only" => false}
        changeset = User.running_changeset(user, params)
        IO.puts "initialize_meta_data for user #{user.id}"
        IO.inspect(changeset)
        Repo.update(changeset)
    end

  def update_read_only(user, value) do
      params = %{"read_only" => value}
      changeset = User.running_changeset(user, params)
      IO.puts "update_read_only, for user #{user.id}"
      IO.inspect(changeset)
      Repo.update(changeset)
  end

  def set_demo(value) do
     user = Repo.get!(User, 23)
     update_read_only(user, value)
  end



  end
