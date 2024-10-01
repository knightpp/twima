defmodule Twima.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create table(:apps) do
      add :client_id, :string, null: false
      add :client_secret, :string, null: false
      add :url, :string, null: false

      timestamps(type: :utc_datetime)
    end

    unique_index(:apps, :url)
  end
end
