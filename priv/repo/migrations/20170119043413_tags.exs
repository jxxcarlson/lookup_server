defmodule LookupPhoenix.Repo.Migrations.Tags do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :tags, {:array, :string}
    end
  end
end
