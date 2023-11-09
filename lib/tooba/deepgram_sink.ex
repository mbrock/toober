defmodule Tooba.DeepgramSink do
  use Membrane.Sink

  @impl true
  def handle_init(_ctx, %{deepgram_opts: deepgram_opts}) do
    # Start the WebSocket client and keep the pid to send messages later
    {:ok, ws_pid} = Deepgram.start_link(deepgram_opts)
    {[], %{ws_pid: ws_pid}}
  end

  @impl true
  def handle_info({:websocket, {:text, json}}, _ctx, state) do
    # Log the JSON message from Deepgram
    IO.inspect(json, label: "Received JSON from Deepgram")
    {[], state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, %{ws_pid: ws_pid} = state) do
    # Assuming buffer contains the audio data
    # Send the audio data to the WebSocket client as a binary frame
    WebSockex.send_frame(ws_pid, {:binary, buffer.payload})
    {[], state}
  end

  def_options(
    deepgram_opts: [
      spec: any()
    ]
  )

  alias Tooba.Deepgram

  @impl true
  def handle_init(_ctx, %{deepgram_opts: deepgram_opts}) do
    # Start the WebSocket client and keep the pid to send messages later
    {:ok, ws_pid} = Deepgram.start_link(deepgram_opts)
    {[], %{ws_pid: ws_pid}}
  end

  @impl true
  def handle_info({:websocket, {:text, json}}, _ctx, state) do
    # Log the JSON message from Deepgram
    IO.inspect(json, label: "Received JSON from Deepgram")
    {[], state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, %{ws_pid: ws_pid} = state) do
    # Assuming buffer contains the audio data
    # Send the audio data to the WebSocket client as a binary frame
    WebSockex.send_frame(ws_pid, {:binary, buffer.payload})
    {[], state}
  end
end
