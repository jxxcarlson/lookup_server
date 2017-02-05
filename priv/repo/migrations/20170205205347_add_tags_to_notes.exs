defmodule LookupPhoenix.Repo.Migrations.AddTagsToNotes do
  use Ecto.Migration

  def change do
    alter table(:notes) do
       add :tags, {:array, :string}
    end
  end
end
