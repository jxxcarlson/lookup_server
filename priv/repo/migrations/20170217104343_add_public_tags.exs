defmodule LookupPhoenix.Repo.Migrations.AddPublicTags do
  use Ecto.Migration

   def change do
      alter table(:users) do
        add :public_tags, {:array, :string}
      end
    end
end
