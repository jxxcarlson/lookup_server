defmodule LookupPhoenix.Repo.Migrations.AddParentToNote do
  use Ecto.Migration

    def change do
       alter table(:notes) do
         add :parent_id, :integer
       end
     end

end
