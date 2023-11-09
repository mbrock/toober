defmodule Tooba.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :uuid, :binary_id, primary_key: true
    field :timestamp, :naive_datetime_usec
    field :payload, :map
    field :resource_type, :string
    field :resource_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:uuid, :timestamp, :payload, :resource_type, :resource_id])
    |> validate_required([:uuid, :timestamp, :payload, :resource_type, :resource_id])
  end
end
