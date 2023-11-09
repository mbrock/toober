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

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  # Define other necessary callbacks such as handle_disconnect/2 if needed
end
