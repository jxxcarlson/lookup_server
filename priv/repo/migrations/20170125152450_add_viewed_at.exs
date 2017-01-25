defmodule LookupPhoenix.Repo.Migrations.AddViewedAt do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :viewed_at, :utc_datetime
    end

  end
end
