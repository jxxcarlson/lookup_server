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
      field :admin, :boolean
      field :number_of_searches, :integer
      field :search_filter, :string

      has_many :notes, LookupPhoenix.Note

      timestamps()
    end

  def running_changeset(model, params \\ :empty) do
      model
      |> cast(params, ~w(tags read_only number_of_searches search_filter), [] )
  end

  def password_changeset(model, params \\ :empty) do
        model
        |> cast(params, ~w(password_hash), [] )
    end

  def admin_changeset(model, params \\ :empty) do
        model
        |> cast(params, ~w(admin), [] )
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username email password registration_code), [] )
    |> validate_length(:username, min: 1, max: 20)
    |> validate_inclusion(:registration_code, ["student", "ladidah", "uahs"])
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


  def change_password(user, password) do
    password_hash = Comeonin.Bcrypt.hashpwsalt(password)
    params = %{"password_hash" => password_hash}
    changeset = password_changeset(user, params)
    Repo.update(changeset)
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
     # params = %{"tags" => [], "read_only" => false, "admin" => false, "number_of_searches"  => 0}
     params = %{"tags" => [], "read_only" => false, "admin" => false, "number_of_searches"  => 0, "search_filter" => " "}
     changeset = User.running_changeset(user, params)
     Repo.update(changeset)
  end

  def update_read_only(user, value) do
      params = %{"read_only" => value}
      changeset = User.running_changeset(user, params)
      Repo.update(changeset)
  end

  def set_admin(user, value) do
     params = %{"admin" => value}
     changeset = User.admin_changeset(user, params)
     Repo.update(changeset)
  end

  def set_name(user, value) do
    params = %{"name" => value}
    changeset = User.changeset(user, params)
       Repo.update(changeset)
  end

  def init_number_of_searches(user) do
    params = %{"number_of_searches" =>0}
    changeset = User.running_changeset(user, params)
    Repo.update(changeset)
  end

  def increment_number_of_searches(user) do
    params = %{"number_of_searches" => user.number_of_searches + 1}
    changeset = User.running_changeset(user, params)
    Repo.update(changeset)
  end

  # say 'set_demo("edit")' or 'set_demo("locked")'
  def set_demo(state) do
     if state == "edit" do
       read_only = false
     else
       read_only = true
     end
     user = Repo.get!(User, 23)
     update_read_only(user, read_only)
  end

  def delete_by_id(id) do
    user = User |> Repo.get(id)
    Repo.delete!(user)
  end

  def init_meta_all do
    users = User |> Repo.all |> Enum.filter(fn(user) -> user.id != 9 end)
    Enum.map(users, fn(user) -> initialize_metadata(user) end)
  end



  end
