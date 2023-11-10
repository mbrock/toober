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
      field :model, :string, default: "general"
      field :tier, :string, default: "base"
      field :version, :string, default: "latest"
      field :language, :string, default: "en"
      field :punctuate, :boolean
      field :paragraphs, :boolean
      field :profanity_filter, :boolean, default: false
      field :diarize, :boolean
      field :diarize_version, :string
      field :smart_format, :boolean
      field :filler_words, :boolean
      field :multichannel, :boolean, default: false
      field :alternatives, :integer, default: 1
      field :numerals, :boolean
      field :interim_results, :boolean
      field :tag, :string
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
        :tier,
        :version,
        :language,
        :punctuate,
        :paragraphs,
        :profanity_filter,
        :diarize,
        :diarize_version,
        :smart_format,
        :filler_words,
        :multichannel,
        :alternatives,
        :tag,
        :numerals,
        :interim_results
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

    def start_link(opts \\ %{}) do
      headers = Tooba.Deepgram.authorization_headers()
      params = Tooba.Deepgram.build_query_params(opts) |> URI.encode_query()

      url = "wss://api.deepgram.com/v1/listen?" <> params
      IO.inspect(params, label: "Params")
      IO.inspect(headers, label: "Headers")

      session = Tooba.gensym()

      WebSockex.start_link(url, __MODULE__, %{session: session}, extra_headers: headers)
    end

    def handle_frame({:text, msg}, state) do
      case Jason.decode(msg) do
        {:ok,
         %{
           "type" => "Results",
           "channel" => %{"alternatives" => alternatives},
           "metadata" => %{"request_id" => _request_id}
         }} ->
          transcript = Enum.map(alternatives, fn alt -> alt["transcript"] end)
          IO.puts("Transcript: #{Enum.join(transcript, " ")}")

        {:error, _} ->
          IO.puts("Error parsing JSON message")
      end

      {:ok, state}
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
