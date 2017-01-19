defmodule LookupPhoenix.Repo.Migrations.AddRegistrationCode do
  use Ecto.Migration

  def change do
        alter table(:users) do
          add :registration_code, :string
        end
    end
end
