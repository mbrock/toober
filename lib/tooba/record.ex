# Let's use Membrane with PortAudio to record audio from the microphone
# and send it to Deepgram for transcription.

defmodule Tooba.TranscriptionSink do
  use Membrane.Sink

  def_input_pad(:input, flow_control: :auto, accepted_format: %Membrane.Matroska{})
end

defmodule Tooba.Record do
  use Membrane.Pipeline

  @impl true
  def handle_init(_, _) do
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
      # Replace Tooba.TranscriptionSink with Tooba.DeepgramSink and pass options
      |> child(Tooba.DeepgramSink, deepgram_opts)

    {[spec: spec], %{}}
  end
end
