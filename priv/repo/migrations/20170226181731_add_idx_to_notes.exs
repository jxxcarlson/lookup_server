defmodule LookupPhoenix.Repo.Migrations.AddIdxToNotes do
  use Ecto.Migration


   def change do
        alter table(:notes) do
          add :idx, :integer, default: -1
        end
    end

end
