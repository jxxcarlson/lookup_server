defmodule LookupPhoenix.Repo.Migrations.RevertToOldTagModel do
  use Ecto.Migration

  def change do
      alter table(:users) do
          remove :public_tags
          remove :tags

          add :public_tags, {:array, :map}, default: []
          add :tags, {:array, :map}, default: []
      end
  end

end
