defmodule LookupPhoenix.Repo.Migrations.AddTagString do
  use Ecto.Migration

  def change do
      alter table(:notes) do
        add :tag_string, :string
      end

  end
end
