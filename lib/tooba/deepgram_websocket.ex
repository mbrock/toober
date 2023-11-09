defmodule Tooba.DeepgramWebsocket do
  use WebSockex

  # Replace with your actual API key
  @api_key "your-api-key"

  def start_link() do
    headers = [{"Authorization", "Token #{@api_key}"}]
    Websockex.start_link("wss://api.deepgram.com/v1/listen", __MODULE__, nil, headers: headers)
  end

  def handle_connect(conn, state) do
    IO.puts("Connected to Deepgram WebSocket")
    {:ok, state}
  end

  def handle_frame({:text, msg}, conn, state) do
    IO.inspect(msg)
    {:ok, state}
  end

  def handle_cast({:send_audio, audio_data}, conn) do
    Websockex.send_frame(conn, {:binary, audio_data})
    {:noreply, state}
  end

  # Define other necessary callbacks such as handle_disconnect/2 if needed
end
