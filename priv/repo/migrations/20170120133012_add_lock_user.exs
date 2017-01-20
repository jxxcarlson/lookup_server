defmodule LookupPhoenix.Repo.Migrations.AddLockUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
        add :read_only, :boolean
   end
  end
end
