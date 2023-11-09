defmodule Tooba.OpenAI do
  @base_url "https://api.openai.com/"

  def new(token) do
    Tesla.client([
      {Tesla.Middleware.BearerAuth, token: token},
      {Tesla.Middleware.BaseUrl, @base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"OpenAI-Beta", "assistants=v1"}
       ]}
    ])
  end

  def new() do
    case System.get_env("OPENAI_API_TOKEN") do
      nil -> raise "OPENAI_API_TOKEN environment variable not set"
      token -> new(token)
    end
  end

  def create_completion(client, prompt, options \\ %{}) do
    client
    |> Tesla.post("/v1/engines/davinci/completions", Map.merge(%{prompt: prompt}, options))
    |> handle_response()
  end

  # curl https://api.openai.com/v1/threads/thread_abc123/messages \
  # -H "Content-Type: application/json" \
  # -H "Authorization: Bearer $OPENAI_API_KEY" \
  # -H "OpenAI-Beta: assistants=v1" \
  # -d '{
  #     "role": "user",
  #     "content": "How does AI work? Explain it in simple terms."
  #   }'

  def create_message(client, thread_id, content) do
    client
    |> Tesla.post("/v1/threads/#{thread_id}/messages", %{role: "user", content: content})
    |> handle_response()
  end

  # curl https://api.openai.com/v1/threads/thread_BDDwIqM4KgHibXX3mqmN3Lgs/runs \
  # -H 'Authorization: Bearer $OPENAI_API_KEY' \
  # -H 'Content-Type: application/json' \
  # -H 'OpenAI-Beta: assistants=v1' \
  # -d '{
  #   "assistant_id": "asst_nGl00s4xa9zmVY6Fvuvz9wwQ"
  # }'

  def create_run(client, thread_id, assistant_id) do
    client
    |> Tesla.post("/v1/threads/#{thread_id}/runs", %{assistant_id: assistant_id})
    |> handle_response()
  end

  # curl https://api.openai.com/v1/threads/thread_BDDwIqM4KgHibXX3mqmN3Lgs/runs/run_5pyUEwhaPk11vCKiDneUWXXY \
  # -H 'Authorization: Bearer $OPENAI_API_KEY' \
  # -H 'OpenAI-Beta: assistants=v1'

  def get_run(client, thread_id, run_id) do
    client
    |> Tesla.get("/v1/threads/#{thread_id}/runs/#{run_id}")
    |> handle_response()
  end

  def parse_call(%{"id" => id, "function" => %{"name" => function, "arguments" => argumentsJSON}}) do
    # parse arguments as JSON with Jason
    arguments = Jason.decode!(argumentsJSON)
    {id, function, arguments}
  end

  def check_run(%{
        "status" => "requires_action",
        "required_action" => %{"submit_tool_outputs" => %{"tool_calls" => calls}}
      }) do
    {:call, Enum.map(calls, &parse_call/1)}
  end

  def check_run(%{"status" => "completed"}) do
    :ok
  end

  def execute_call(function_map, {_id, function, arguments}) do
    function_map[function].(arguments)
  end

  def execute_calls(function_map, calls) do
    Enum.map(calls, &execute_call(function_map, &1))
  end

  def zigbee_function_map do
    %{
      "set_lamp" => fn %{
                         "device_id" => device_id,
                         "brightness" => brightness,
                         "temperature" => temperature
                       } ->
        brightness_value = brightness / 100.0 * 255
        temperature_value = temperature / 100.0 * 255

        Tooba.Zigbee.set_state(device_id, true, %{
          "brightness" => brightness_value,
          "temperature" => temperature_value
        })
      end
    }
  end

  def list_assistants(client) do
    client
    |> Tesla.get("/v1/assistants")
    |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
  end

  def example_usage do
    client = new()
    {:ok, completion} = create_completion(client, "Once upon a time", %{max_tokens: 5})
    IO.inspect(completion)
  end
end
