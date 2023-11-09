defmodule Tooba.ZigbeeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tooba.Zigbee` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        inserted_at: ~N[2023-11-03 21:26:00],
        payload: %{},
        topic: "some topic"
      })
      |> Tooba.Zigbee.create_message()

    message
  end
end
