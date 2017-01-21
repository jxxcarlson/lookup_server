defmodule LookupPhoenix.Repo.Migrations.AddNumberOfSearches do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :number_of_searches, :integer
    end

  end
end
