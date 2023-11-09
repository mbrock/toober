defmodule Tooba.DeepgramSink do
  use Membrane.Sink

  alias Tooba.Deepgram

  @impl true
  def handle_init(opts) do
    # Start the WebSocket client and keep the pid to send messages later
    {:ok, ws_pid} = Deepgram.start_link(opts)
    {:ok, %{ws_pid: ws_pid}}
  end

  @impl true
  def handle_write(_buffer, %{ws_pid: ws_pid} = state) do
    # Here you would convert the buffer to the format expected by Deepgram
    # and send it through the WebSocket connection
    # This is a placeholder for the actual implementation
    # Deepgram.send_audio(ws_pid, converted_buffer)

    {:ok, state}
  end

  # Implement other callbacks such as handle_prepared_to_playing/1 if needed
end
