# Let's use Membrane with PortAudio to record audio from the microphone
# and send it to Deepgram for transcription.

defmodule Tooba.Record do
  use Membrane.Pipeline

  @impl true
  def handle_init(_) do
    children = [
      portaudio: %Membrane.PortAudio.Source{
        input_device: :default,
        sample_rate: 48_000,
        channels: 2,
        format: :s16le,
        latency: 20
      },
      opus: Membrane.Opus.Encoder,
      matroska: %Membrane.Matroska.Muxer{
        output_path: "output.mkv"
      }
    ]

    links = [
      link(:portaudio)
      |> to(:opus)
      |> to(:matroska)
    ]

    spec = %Membrane.Pipeline.Spec{
      children: children,
      links: links
    }

    {{:ok, spec}, %{}}
  end
end
