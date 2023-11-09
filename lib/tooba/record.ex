defmodule Tooba.Record do
  def start_ffmpeg_stream do
    command = "ffmpeg"
    args = [
      "-f", "pulse", # or "alsa" for ALSA on Linux, "avfoundation" for macOS, etc.
      "-i", "default", # this might be different depending on your system
      "-acodec", "libopus",
      "-f", "webm",
      "-content_type", "audio/webm",
      "pipe:1"
    ]

    port = Port.open({:spawn_executable, command}, [:binary, args: args, exit_status: true])

    # Now you can read from the port to get the audio data
    # You would typically pass the port to a process that will handle the data
    # For example:
    # {:ok, pid} = Task.start_link(fn -> read_audio_data(port) end)

    {:ok, port}
  end

  defp read_audio_data(port) do
    receive do
      {^port, {:data, data}} ->
        # Handle the chunk of audio data here
        # For example, you could send it to the Deepgram API for transcription
        IO.inspect(data)
        read_audio_data(port)

      {^port, {:exit_status, status}} ->
        # ffmpeg has exited, handle the exit status if needed
        IO.puts("ffmpeg exited with status: #{status}")
    end
  end
end
