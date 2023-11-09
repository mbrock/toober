defmodule Tooba.DeepgramSink do
  use Membrane.Sink

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
  def handle_info({:data, data}, _ctx, %{ws_pid: ws_pid} = state) do
    # Send the audio data to the WebSocket client
    WebSockex.send_frame(ws_pid, {:binary, data})
    {[], state}
  end
end
