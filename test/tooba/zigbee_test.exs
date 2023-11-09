defmodule Tooba.ZigbeeTest do
  use Tooba.DataCase

  alias Tooba.Zigbee

  describe "messages" do
    alias Tooba.Zigbee.Message

    import Tooba.ZigbeeFixtures

    @invalid_attrs %{payload: nil, topic: nil, inserted_at: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Zigbee.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Zigbee.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{payload: %{}, topic: "some topic", inserted_at: ~N[2023-11-03 21:26:00]}

      assert {:ok, %Message{} = message} = Zigbee.create_message(valid_attrs)
      assert message.payload == %{}
      assert message.topic == "some topic"
      assert message.inserted_at == ~N[2023-11-03 21:26:00]
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Zigbee.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{payload: %{}, topic: "some updated topic", inserted_at: ~N[2023-11-04 21:26:00]}

      assert {:ok, %Message{} = message} = Zigbee.update_message(message, update_attrs)
      assert message.payload == %{}
      assert message.topic == "some updated topic"
      assert message.inserted_at == ~N[2023-11-04 21:26:00]
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Zigbee.update_message(message, @invalid_attrs)
      assert message == Zigbee.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Zigbee.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Zigbee.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Zigbee.change_message(message)
    end
  end
end
