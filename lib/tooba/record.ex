# Let's use Membrane with PortAudio to record audio from the microphone
# and send it to Deepgram for transcription.

defmodule Tooba.Record do
  use Membrane.Pipeline
  use RDF
  alias Tooba.NS.K

  @impl true
  def handle_init(_ctx, %{session: session, deepgram_opts: deepgram_opts}) do
    sample_rate = 48_000
    channels = 1

    deepgram_opts =
      Map.merge(
        deepgram_opts,
        %{sample_rate: sample_rate, channels: channels, encoding: "linear16"}
      )

    spec =
      child(%Membrane.PortAudio.Source{
        endpoint_id: :default,
        sample_rate: sample_rate,
        channels: channels,
        sample_format: :s16le
      })
      |> child(%Tooba.DeepgramSink{session: session, deepgram_opts: deepgram_opts})

    Tooba.know!({session, RDF.type(), K.RecordingSession})

    {[spec: spec], %{}}
  end

  # Demo function to start and stop the pipeline after 5 seconds
  def demo do
    recording_session = Tooba.gensym()

    # Start the pipeline
    {:ok, _supervisor_pid, pid} =
      Tooba.Record.start_link(%{
        session: recording_session
      })

    # Wait for 10 seconds
    :timer.sleep(10_000)

    # Stop the pipeline
    :ok = Membrane.Pipeline.terminate(pid)
  end
end
