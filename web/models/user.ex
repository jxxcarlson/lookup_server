

defmodule LookupPhoenix.User do
  use LookupPhoenix.Web, :model

  use Ecto.Schema
  import Ecto.Query

  alias LookupPhoenix.Repo
  alias LookupPhoenix.Tag
  alias LookupPhoenix.User
  alias LookupPhoenix.Utility


  schema "users" do
      field :name, :string
      field :username, :string
      field :email, :string
      field :password, :string
      field :password_hash, :string
      field :registration_code, :string
      field :tags, {:array, :map }
      field :public_tags, {:array, :map }
      field :read_only, :boolean
      field :admin, :boolean
      field :number_of_searches, :integer
      field :search_filter, :string
      field :channel, :string
      field :preferences, :map
      field :public, :boolean
      field :blurb, :string

      has_many :notes, LookupPhoenix.Note

      timestamps()
    end

  def running_changeset(model, params \\ :empty) do
      model
      |> cast(params, ~w(public blurb tags public_tags read_only number_of_searches search_filter channel), [] )
  end

  def preferences_changeset(model, params \\ :empty) do
        model
        |> cast(params, ~w(preferences), [] )
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
    |> cast(params, ~w(name username email password registration_code channel), [] )
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

    def decode_channel(user) do
        IO.puts "DECODE CHANNEL"
        user_id = user.id
        access = :public

        [channel_user_name, channel_name] = String.split(user.channel, ".")

        if channel_user_name == user.username do
          access = :all
          user_id = user.id
        else
          channel_user = User.find_by_username(channel_user_name)
          if channel_user == nil do
            user_id = user.id
          else
            user_id = channel_user.id
          end
        end

        case channel_name do
          "public" -> access = :public
          "nonpublic" -> access = :nonpublic
          _ -> :all
        end

        [access, channel_name, user_id]
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

  def find_by_username(username) do
    Repo.one(from u in User, where: u.username == ^username)
   end

   def public_users do
     Repo.all(from u in User, where: u.public == true)
   end


  def set_read_only(changeset, value) do
        case changeset do
          %Ecto.Changeset{valid?: true, changes: %{read_only: value}} ->
            put_change(changeset, :read_only, value)
          _ ->
            changeset
        end
    end

  # Enum.map(uu, fn(user) -> Repo.update(User.running_changeset(user, params)) end)

  def update_tags(user) do
      # tags = Tag.get_all_user_tags(user) |> Enum.sort
      tags = Tag.tags_by_frequency(:all, user)
      IO.puts "Updating #{length(tags)} tags"
      params = %{"tags" => tags}
      changeset = User.running_changeset(user, params)
      Repo.update(changeset)

      # tags = Tag.get_all_public_user_tags(user) |> Enum.sort
      tags = Tag.tags_by_frequency(:public, user)
      IO.puts "Updating #{length(tags)} public tags"
      params = %{"public_tags" => tags}
      changeset = User.running_changeset(user, params)
      Repo.update(changeset)
  end

  def update_channel(user,channel) do
        IO.puts "XXX: Changing channel to #{channel} for user #{user.username}"
        params = %{"channel" => channel}
        changeset = User.running_changeset(user, params)
        Repo.update(changeset)
  end

  def update_user(user,params) do
     changeset = User.running_changeset(user, params)
      Repo.update(changeset)
  end

  def update_preferences(user,prefs) do
       changeset = User.preferences_changeset(user, %{preferences: prefs})
        Repo.update(changeset)
  end

  def get_preference(user, pref) do
    cond do
      user.preferences == nil -> ""
      !Enum.member?(Map.keys(user.preferences), pref) -> ""
      true -> user.preferences[pref]
    end
  end

  def initialize_metadata(user) do
     IO.puts "1. initialize_metadata"
     params = %{ "public" => false,  "blurb" => "-", "tags" => [], "public_tags" => [], "read_only" => false, "admin" => false,
        "number_of_searches"  => 0, "search_filter" => "-", "channel" => "#{user.username}.all"}
     changeset = User.running_changeset(user, params)
     params2 = %{"preferences" => %{}}
     changeset2 = User.preferences_changeset(user, params2)
     Utility.report("XXXXXXXX: changeset", changeset)
     Utility.report("YYYYYYYY: changeset", changeset2)
     Repo.update(changeset)
     Repo.update(changeset2)
     IO.puts "2. initialize_metadata"
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
    if user != nil do
      params = %{"number_of_searches" => user.number_of_searches + 1}
      changeset = User.running_changeset(user, params)
      Repo.update(changeset)
    end
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

  def set_channel(user, channel) do
    params = %{"channel" => channel}
    IO.puts "I AM GOING TO DEFINITELY SET YOUR CHANNEL TO #{channel}"
    Utility.report("params = ", params)

    changeset = User.running_changeset(User, params)


    Utility.report("CHANGESET FOR SET CHANNEL", changeset)
    Repo.update(changeset)
  end

  ### ONE TIME ###

  def set_public_tags(user) do
      params = %{"public_tags" => []}
      changeset = User.running_changeset(user, params)
      Repo.update(changeset)
  end

  def set_all_public_tags do
    User |> Repo.all |> Enum.map(fn(user) -> set_public_tags(user) end)
  end

  def fix_public(user) do
    if user.public == nil do
       params = %{"public" => false}
       changeset = User.running_changeset(user, params)
       Repo.update(changeset)
    end
   end

   # def apply_to_users(ff) do
   #  User |> Repo.all |> Enum.map(fn(user) -> ff(user) end)
   # end

  end
