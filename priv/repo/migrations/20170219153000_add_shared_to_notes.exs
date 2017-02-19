defmodule LookupPhoenix.Repo.Migrations.AddSharedToNotes do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :shared, :boolean, default: false
    end
  end
end
