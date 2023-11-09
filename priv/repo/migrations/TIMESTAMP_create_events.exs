defmodule Tooba.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :uuid, :binary_id, primary_key: true
      add :timestamp, :naive_datetime_usec
      add :payload, :map
      add :resource_type, :string
      add :resource_id, :binary_id

      timestamps()
    end
  end
end
