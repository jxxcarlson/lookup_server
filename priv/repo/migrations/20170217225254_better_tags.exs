defmodule LookupPhoenix.Repo.Migrations.BetterTags do
  use Ecto.Migration

   def change do
      alter table(:users) do
          remove :public_tags
          remove :tags
          add :public_tags, :map
          add :tags, :map
      end
    end

end
