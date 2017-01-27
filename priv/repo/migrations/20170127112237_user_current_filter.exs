defmodule LookupPhoenix.Repo.Migrations.UserCurrentFilter do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :search_fitter, :string
    end

  end
end
