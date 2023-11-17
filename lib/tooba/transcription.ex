defmodule Tooba.Transcription.Sink do
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

  def_options(session: [spec: any()])

  @impl true
  def handle_init(_ctx, %{session: session}) do
    {:ok, ws_pid} =
      Tooba.Deepgram.Streaming.start_link(%{session: session})

    {[], %{ws_pid: ws_pid, session: session}}
  end
end

defmodule Tooba.Transcription.Pipeline do
  use Membrane.Pipeline

  def source_definition(:microphone) do
    %Membrane.PortAudio.Source{
      sample_rate: 48_000,
      channels: 1,
      sample_format: :s16le
    }
  end

  def sink_definition(:deepgram) do
    %Tooba.Transcription.Sink{session: nil}
  end
end
