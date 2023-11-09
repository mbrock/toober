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
        :detect_language,
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
        :paragraphs,
        :summarize,
        :detect_topics,
        :utterances,
        :utt_split,
        :tag,
        :numerals,
        :ner,
        :measurements,
        :dictation
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
      field :detect_language, :boolean, default: false
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
      field :paragraphs, :boolean, default: false
      field :summarize, :string, default: "v2"
      field :detect_topics, :boolean, default: false
      field :utterances, :boolean, default: false
      field :utt_split, :float, default: 0.8
      field :tag, :string
      field :numerals, :boolean, default: false
      field :ner, :boolean, default: false
      field :measurements, :boolean, default: false
      field :dictation, :boolean, default: false
    end
  end

  @base_url "https://api.deepgram.com/"

  def new(api_key) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Headers, [{"Authorization", "Token #{api_key}"}]},
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