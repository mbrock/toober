defmodule Tooba.Deepgram do
  @moduledoc """
  A client for interacting with the Deepgram speech-to-text API.
  It provides support for both streaming and prerecorded audio transcription.
  """

  @base_url "https://api.deepgram.com/"

  defmodule RequestParams do
    use Ecto.Schema

    # Fields definitions
    embedded_schema do
      field :encoding, :string
      field :sample_rate, :integer
      field :channels, :integer
      field :model, :string, default: "nova-2"
      field :language, :string, default: "en"
      field :smart_format, :boolean
      field :multichannel, :boolean, default: false
      field :interim_results, :boolean
      field :tag, :string
      field :utterances, :boolean, default: false
    end

    # Functions for processing request parameters
    def changeset(params, attrs) do
      params
      |> Ecto.Changeset.cast(attrs, permitted_fields())
      |> Ecto.Changeset.validate_required(required_fields())
    end

    defp permitted_fields do
      [
        :encoding,
        :sample_rate,
        :channels,
        :model,
        :language,
        :smart_format,
        :multichannel,
        :tag,
        :interim_results,
        :utterances
      ]
    end

    defp required_fields, do: []
  end

  def build_query_params(opts) do
    RequestParams.changeset(%RequestParams{}, opts)
    |> Ecto.Changeset.apply_changes()
    |> Map.delete(:__struct__)
    |> Map.to_list()
    |> Enum.filter(fn {_k, v} -> v != nil end)
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
  end

  def authorization_headers do
    [{"Authorization", "Token #{api_key()}"}]
  end

  def api_key do
    Application.get_env(:tooba, :deepgram_api_key)
  end

  # Nested module for streaming transcription
  defmodule Streaming do
    use WebSockex
    use RDF

    require Logger

    def start_link(%{session: session, deepgram_opts: opts}) do
      headers = Tooba.Deepgram.authorization_headers()
      params = Tooba.Deepgram.build_query_params(opts) |> URI.encode_query()

      url = "wss://api.deepgram.com/v1/listen?" <> params
      IO.inspect(params, label: "Params")
      IO.inspect(headers, label: "Headers")

      case WebSockex.start_link(url, __MODULE__, %{session: session}, extra_headers: headers) do
        {:ok, pid} ->
          {:ok, pid}

        {:error, reason} ->
          Logger.error("Error starting WebSockex: #{inspect(reason)}")
          {:error, reason}
      end
    end

    def handle_frame({:text, msg}, state) do
      case Jason.decode(msg) do
        {:ok,
         %{
           "type" => "Results",
           "channel" => %{"alternatives" => alternatives},
           "metadata" => %{"request_id" => _request_id},
           "is_final" => is_final
         } = result} ->
          case Enum.map(alternatives, fn alt -> alt["transcript"] end) do
            [""] ->
              nil

            transcripts ->
              entity = Tooba.gensym()

              Tooba.know!([
                {entity, RDF.type(), ~I<https://node.town/TranscriptionResult>},
                {entity, ~I<https://node.town/transcription>, transcripts},
                {entity, ~I<https://node.town/timestamp>, DateTime.utc_now()},
                {entity, ~I<https://node.town/json>, Jason.encode!(result)},
                {entity, ~I<https://node.town/session>, state[:session]},
                {entity, ~I<https://node.town/isFinal>, is_final}
              ])
          end

        {:error, _} ->
          IO.puts("Error parsing JSON message")
      end

      {:ok, state}
    end

    def handle_frame({:binary, _msg}, state) do
      IO.puts("Received binary message")
      {:ok, state}
    end

    def terminate(reason, _state) do
      IO.inspect(reason, label: "Terminating")
      :ok
    end

    def handle_disconnect(connection_status_map, state) do
      IO.puts("Disconnected - Status: #{inspect(connection_status_map)}")
      {:ok, state}
    end

    def handle_info(msg, state) do
      IO.puts("Received Info - Message: #{inspect(msg)}")
      {:ok, state}
    end
  end

  # Nested module for prerecorded audio transcription
  defmodule Prerecorded do
    def transcribe(audio_data, opts \\ %{}) do
      Req.post(
        "https://api.deepgram.com/v1/listen",
        body: audio_data,
        headers: Tooba.Deepgram.authorization_headers(),
        params: Tooba.Deepgram.build_query_params(opts)
      )
    end
  end
end
