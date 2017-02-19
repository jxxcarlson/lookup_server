defmodule LookupPhoenix.Repo.Migrations.AddTokensToNotes do
  use Ecto.Migration

   def change do
      alter table(:notes) do
          add :tokens, {:array, :map}, default: []
      end
    end
end
