defmodule LookupPhoenix.Repo.Migrations.AddAttributesToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :public, :boolean, default: false
      add :blurb, :text
    end
  end
end
