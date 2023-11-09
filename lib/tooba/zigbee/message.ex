defmodule Tooba.Zigbee.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :payload, :map
    field :topic, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:topic, :payload])
    |> validate_required([:topic])
  end
end
