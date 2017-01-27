defmodule LookupPhoenix.Repo.Migrations.UserCurrentFilter2 do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :search_fitter
    end

     alter table(:users) do
          add :search_filter, :string
     end

  end
end
