# Let's use Membrane with PortAudio to record audio from the microphone
# and send it to Deepgram for transcription.

defmodule Tooba.Record do
  use Membrane.Pipeline

  @impl true
  def handle_init(_ctx, opts) do
    deepgram_opts = opts[:deepgram_opts] || %{}
    sample_rate = Map.get(deepgram_opts, :sample_rate, 48_000)
    channels = Map.get(deepgram_opts, :channels, 1)

    spec =
      child(%Membrane.PortAudio.Source{
        endpoint_id: :default,
        sample_rate: sample_rate,
        channels: channels,
        sample_format: :s16le
      })
      |> child(%Tooba.DeepgramSink{deepgram_opts: deepgram_opts})

    {[spec: spec], %{}}
  end

  # Demo function to start and stop the pipeline after 5 seconds
  def demo do
    # Start the pipeline
    {:ok, _supervisor_pid, pid} = Tooba.Record.start_link(%{})

    # Wait for 5 seconds
    :timer.sleep(5_000)

    # Stop the pipeline
    :ok = Membrane.Pipeline.terminate(pid)
  end
end
