defmodule Tooba.Deepgram do
  @moduledoc """
  A client for interacting with the Deepgram speech-to-text API.
  """

  defmodule RequestParams do
    use Ecto.Schema

    @doc false
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
        :profanity_filter,
        :redact,
        :diarize,
        :diarize_version,
        :smart_format,
        :filler_words,
        :multichannel,
        :alternatives,
        :search,
        :replace,
        :callback,
        :keywords,
        :tag,
        :numerals,
        :interim_results
      ]
    end

    defp required_fields do
      []
    end

    embedded_schema do
      field :encoding, :string
      field :sample_rate, :integer
      field :channels, :integer
      field :model, :string, default: "general"
      field :tier, :string, default: "base"
      field :version, :string, default: "latest"
      field :language, :string, default: "en"
      field :punctuate, :boolean, default: false
      field :profanity_filter, :boolean, default: false
      field :diarize, :boolean, default: false
      field :diarize_version, :string
      field :smart_format, :boolean, default: false
      field :filler_words, :boolean, default: false
      field :multichannel, :boolean, default: false
      field :alternatives, :integer, default: 1
      field :numerals, :boolean, default: false
      field :interim_results, :boolean, default: true
    end
  end

  @base_url "https://api.deepgram.com/"

  defp api_key do
    Application.get_env(:tooba, :deepgram_api_key)
  end

  use WebSockex

  def start_link(opts \\ %{}) do
    headers = [{"Authorization", "Token #{api_key()}"}]

    params =
      RequestParams.changeset(%RequestParams{}, opts)
      |> Ecto.Changeset.apply_changes()
      |> Map.delete(:__struct__)
      |> Map.to_list()
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
      |> URI.encode_query()

    url = "wss://api.deepgram.com/v1/listen?" <> params
    IO.inspect(params, label: "Params")
    IO.inspect(headers, label: "Headers")

    WebSockex.start_link(url, __MODULE__, nil, extra_headers: headers)
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

  # Define other necessary callbacks such as handle_disconnect/2 if needed

  def new() do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Headers, [{"Authorization", "Token #{api_key()}"}]},
      Tesla.Middleware.JSON
    ])
  end

  def transcribe_audio(client, audio_data, opts \\ %{}) do
    params =
      RequestParams.changeset(%RequestParams{}, opts)
      |> Ecto.Changeset.apply_changes()

    client
    |> Tesla.post("/v1/listen", audio_data, query: params)
    |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
  end
end
