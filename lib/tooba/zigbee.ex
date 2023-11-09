defmodule Tooba.Zigbee do
  alias Tooba.Repo
  alias Tooba.Zigbee.Message

  require Logger

  use Tortoise.Handler

  def init(_opts) do
    {:ok, nil}
  end

  def handle_message(["zigbee", "bridge", "logging"], x, state) do
    Logger.info("zigbee bridge logging: #{inspect(x)}")
    {:ok, state}
  end

  def handle_message(topic, msg, state) do
    payload =
      case Jason.decode(msg || "") do
        {:ok, payload} -> payload
        {:error, _} -> msg
      end

    # if payload is just a string, convert it to a map
    payload =
      case payload do
        %{} -> payload
        _ -> %{"payload" => payload}
      end

    Logger.info("#{Enum.join(topic, "/")} #{inspect(payload)}")

    Repo.insert!(%Message{topic: Enum.join(topic, "/"), payload: payload})

    handle(topic, payload, state)
  end

  def publish(topic, payload) do
    :ok =
      Tortoise.publish(
        Tooba.Zigbee,
        Enum.join(["zigbee" | topic], "/"),
        Jason.encode!(payload)
      )
  end

  def request_device_rename(name, new_name) do
    publish(
      ["bridge", "request", "device", "rename"],
      %{"from" => name, "to" => new_name}
    )
  end

  def handle(["zigbee", device], payload, state) do
    Phoenix.PubSub.broadcast!(
      Tooba.PubSub,
      "message",
      {:message, device, payload}
    )

    IO.inspect(%{"device" => device, "payload" => payload})

    {:ok, state}
  end

  def handle(topic, data, state) do
    Logger.info("zigbee handler: #{inspect(topic)} #{inspect(data)}")
    {:ok, state}
  end

  def boolean_to_state(true), do: "ON"
  def boolean_to_state(false), do: "OFF"

  def state_to_boolean("ON"), do: true
  def state_to_boolean("OFF"), do: false

  def set_state(device, state, extra \\ %{}) do
    tell(device, Map.merge(%{"state" => boolean_to_state(state)}, extra))
  end

  def tell(device, message) do
    publish([device, "set"], message)
  end

  alias Tooba.Zigbee.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Returns a map from topic to the latest message.

  ## Examples

      iex> latest_messages()
      %{"zigbee/bridge/logging" => %Message{}, ...}

  """
  def latest_messages do
    Repo.all(Message)
    |> Enum.group_by(& &1.topic)
    |> Enum.map(fn {topic, messages} -> {topic, Enum.max_by(messages, & &1.inserted_at)} end)
    |> Enum.into(%{})
  end

  def devices do
    devices =
      latest_messages()
      |> Map.get("zigbee/bridge/devices")
      |> case do
        nil -> nil
        message -> message.payload["payload"]
      end

    Enum.map(devices, fn device ->
      key = device["friendly_name"] || device["ieeeAddr"]
      {key, device}
    end)
    |> Enum.into(%{})
  end

  def devices_with_values do
    messages = latest_messages()
    devices = devices()

    Enum.map(devices, fn {key, device} ->
      values = Map.get(messages, "zigbee/#{key}", %Message{}).payload
      {key, %{info: device, values: values}}
    end)
    |> Enum.into(%{})
  end

  defmodule DeviceInfo do
    def extract_device_features(%{"definition" => %{"exposes" => exposes}}, device_values) do
      # Extract features for both generic and specific exposes
      Enum.reduce(exposes, %{}, fn expose, acc ->
        case expose do
          %{"features" => features} when is_list(features) ->
            # Handle specific types with features property
            Enum.reduce(features, acc, fn feature, acc ->
              process_generic_type(feature, device_values, acc)
            end)

          %{"property" => _} = generic_type ->
            # Handle generic types
            process_generic_type(generic_type, device_values, acc)

          _ ->
            acc
        end
      end)
    end

    def extract_device_features(_device_info, _device_values), do: %{}

    defp process_generic_type(%{"property" => property} = generic_type, device_values, acc) do
      value = Map.get(device_values, property)
      Map.put(acc, property, Map.put(generic_type, "value", value))
    end
  end

  def device_info(%{info: info, values: values}) do
    %{
      info: info,
      values: values,
      features: DeviceInfo.extract_device_features(info, values)
    }
  end

  def devices_with_info do
    devices_with_values()
    |> Enum.map(fn {key, device} -> {key, device_info(device)} end)
    |> Enum.into(%{})
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
