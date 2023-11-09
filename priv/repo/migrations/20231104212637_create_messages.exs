defmodule Tooba.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :topic, :string
      add :payload, :map

      timestamps(type: :utc_datetime)
    end
  end
end
