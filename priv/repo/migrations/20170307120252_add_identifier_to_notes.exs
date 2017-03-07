defmodule LookupPhoenix.Repo.Migrations.AddIdentifierToNotes do
  use Ecto.Migration

  def change do
   alter table(:notes) do
     add :identifier, :string
   end
  create unique_index(:notes, [:identifier])
  end
end
