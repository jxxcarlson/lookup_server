defmodule LookupPhoenix.TestHelpers do
  alias LookupPhoenix.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      username: "morris",
      password: "supesecret"
    }, attrs)

    %LookupPhoenix.User{}
    |> LookupPhoenix.User.registration_changeset(changes)
    |> Repo.insert
  end


end