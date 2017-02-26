defmodule LookupPhoenix.Repo.Migrations.AddDefaultToBlurb do
  use Ecto.Migration

    def change do
          alter table(:users) do
            remove :blurb
            add :blurb, :string, default: "-"
          end
      end
end
