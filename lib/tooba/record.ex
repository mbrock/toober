# Let's use Membrane with PortAudio to record audio from the microphone
# and send it to Deepgram for transcription.

defmodule Tooba.Record do
  use Membrane.Pipeline
  use RDF
  alias Tooba.NS.BFO

  @impl true
  def handle_init(_ctx, %{session: session, deepgram_opts: deepgram_opts}) do
    sample_rate = 48_000
    channels = 1

    deepgram_opts =
      Map.merge(
        deepgram_opts,
        %{sample_rate: sample_rate, channels: channels, encoding: "linear16"}
      )

    subsession = Tooba.gensym()

    Tooba.know!([
      {subsession, RDF.NS.RDF.type(), ~I<https://node.town/TranscriptionProcess>},
      {session, ~I<https://node.town/supervises>, subsession},
      {subsession, ~I<https://node.town/began>, DateTime.utc_now()}
    ])

    spec =
      child(%Membrane.PortAudio.Source{
        endpoint_id: :default,
        sample_rate: sample_rate,
        channels: channels,
        sample_format: :s16le
      })
      |> child(%Tooba.DeepgramSink{session: subsession, deepgram_opts: deepgram_opts})

    {[spec: spec], %{}}
  end

  def demo do
    {:ok, _supervisor_pid, pid} =
      Tooba.Record.start_link(%{
        session: Tooba.session(),
        deepgram_opts: %{
          interim_results: true,
          smart_format: true
        }
      })

    :timer.sleep(30_000)
    :ok = Membrane.Pipeline.terminate(pid)
  end
end
