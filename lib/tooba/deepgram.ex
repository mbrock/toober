defmodule Tooba.Deepgram do
  @moduledoc """
  A client for interacting with the Deepgram speech-to-text API.
  """

  @base_url "https://api.deepgram.com/"

  def new(api_key) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Headers, [{"Authorization", "Token #{api_key}"}]},
      Tesla.Middleware.JSON
    ])
  end

  def transcribe_audio(client, audio_data, opts \\ []) do
    client
    |> Tesla.post("/v1/listen", audio_data, opts)
    |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
  end
end
