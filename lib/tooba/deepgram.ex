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
        :numerals
      ]
    end

    defp required_fields do
      []
    end

    embedded_schema do
      field :model, :string, default: "general"
      field :tier, :string, default: "base"
      field :version, :string, default: "latest"
      field :language, :string, default: "en"
      field :punctuate, :boolean, default: false
      field :profanity_filter, :boolean, default: false
      field :redact, {:array, :string}
      field :diarize, :boolean, default: false
      field :diarize_version, :string
      field :smart_format, :boolean, default: false
      field :filler_words, :boolean, default: false
      field :multichannel, :boolean, default: false
      field :alternatives, :integer, default: 1
      field :search, {:array, :string}
      field :replace, {:array, :string}
      field :callback, :string
      field :keywords, {:array, :string}
      field :tag, :string
      field :numerals, :boolean, default: false
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
      # Remove the __struct__ field
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

  def handle_frame({type, msg}, state) do
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}")
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
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
