defmodule LookupPhoenix.Repo.Migrations.AddAssociation do
  use Ecto.Migration

  def change do
      alter table(:notes) do
        modify :user_id, references(:users)
      end
  end
end
