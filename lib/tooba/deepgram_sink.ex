defmodule Tooba.DeepgramSink do
  use Membrane.Sink

  def_input_pad(:input,
    demand_unit: :buffers,
    demand_mode: :auto,
    accepted_format: %Membrane.RawAudio{
      sample_format: :s16le,
      channels: 1,
      sample_rate: 48_000
    }
  )

  def_options(
    deepgram_opts: [
      spec: any()
    ],
    session: [spec: any()]
  )

  alias Tooba.Deepgram

  @impl true
  def handle_init(_ctx, %{
        session: session,
        deepgram_opts: deepgram_opts
      }) do
    {:ok, ws_pid} =
      Deepgram.Streaming.start_link(%{
        session: session,
        deepgram_opts: deepgram_opts
      })

    {[], %{ws_pid: ws_pid, session: session}}
  end

  @impl true
  def handle_write(
        :input,
        buffer,
        _ctx,
        %{ws_pid: ws_pid} = state
      ) do
    WebSockex.send_frame(ws_pid, {:binary, buffer.payload})
    {[], state}
  end
end
