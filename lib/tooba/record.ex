defmodule Tooba.Record do
  def list_input_sources(format) do
    {output, _exit_code} = System.cmd("ffmpeg", ["-list_devices", "true", "-f", format, "-i", "dummy"], stderr_to_stdout: true)
    # Parse the output to extract device names and return them
    # The parsing will depend on the format of the output, which can vary by platform
    # This is a placeholder for the parsing logic
    devices = parse_device_list(output)
    devices
  end

  defp parse_device_list(output) do
    # Implement parsing logic here based on the expected output format
    # This is a placeholder function
    []
  end

  def start_ffmpeg_stream do
    command = "ffmpeg"
    args = [
      "-f", "pulse", # Replace "pulse" with the actual format you want to use
      "-i", "default", # Replace "default" with the actual input source you want to use
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
