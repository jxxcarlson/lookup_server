defmodule LookupPhoenix.Repo.Migrations.AddChannelAndPubic do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :channel, :string
    end
    alter table(:notes) do
      add :public, :boolean
    end

  end
end
