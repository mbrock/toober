# Let's use Membrane with PortAudio to record audio from the microphone
# and send it to Deepgram for transcription.

defmodule Tooba.Record do
  use Membrane.Pipeline

  @impl true
  def handle_init(_ctx, opts) do
    deepgram_opts = opts[:deepgram_opts] || %{}

    spec =
      child(%Membrane.PortAudio.Source{
        endpoint_id: :default,
        sample_rate: 48_000,
        channels: 2,
        sample_format: :s16le
      })
      |> child(%Membrane.Opus.Encoder{
        application: :audio
      })
      |> child(%Membrane.Matroska.Muxer{})
      |> child(%Tooba.DeepgramSink{deepgram_opts: deepgram_opts})

    {[spec: spec], %{}}
  end
end
