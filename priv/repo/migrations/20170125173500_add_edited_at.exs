defmodule LookupPhoenix.Repo.Migrations.AddEditedAt do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :edited_at, :utc_datetime
    end
  end
end
