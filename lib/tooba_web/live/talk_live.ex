defmodule ToobaWeb.TalkLive do
  use ToobaWeb, :live_view
  use RDF

  alias Tooba.NS.{BFO, K}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Tooba.PubSub, "news")
    end

    {:ok,
     socket
     |> stream_configure(:transcriptions, dom_id: &RDF.IRI.to_string(&1.s))
     |> stream(:transcriptions, transcriptions(Tooba.graph()), limit: 10)
     |> assign(:pid, nil)}
  end

  defp transcriptions(graph) do
    graph
    |> RDF.Graph.query([
      {:s?, ~I<https://node.town/transcription>, :text?},
      {:s?, ~I<https://node.town/timestamp>, :time?},
      {:s?, ~I<https://node.town/isFinal>, :final?},
      {:s?, ~I<https://node.town/json>, :json?}
    ])
    |> Enum.sort_by(fn x -> RDF.Literal.value(x.time) end, &DateTime.before?/2)
    |> remove_old_nonfinals()
  end

  defp remove_old_nonfinals(list) do
    # only keep a single non-final transcription at the end of the list
    # (if there is one)

    list
    |> Enum.reverse()
    |> case do
      [] ->
        []

      [x | xs] ->
        [x | Enum.filter(xs, fn x -> RDF.Literal.value(x.final) end)]
    end
    |> Enum.reverse()
  end

  @impl true
  def handle_info(%{news: _news, graph: graph}, socket) do
    {:noreply, stream(socket, :transcriptions, transcriptions(graph), reset: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="flex flex-col gap-3">
      <article
        id="transcriptions"
        class="flex flex-wrap gap-2 justify-center"
        phx-update="stream"
        phx-hook="scroll to bottom"
      >
        <p
          :for={{dom_id, x} <- @streams.transcriptions}
          id={dom_id}
          class={"border rounded px-4 lowercase " <> if RDF.Literal.value(x.final), do: "", else: "opacity-50"}
        >
          <%= RDF.Literal.value(x.text) %>
        </p>
      </article>
      <button
        class="border p-1 px-2 rounded bg-gray-50 flex flex-col"
        phx-click={if assigns.pid, do: "stop", else: "talk"}
        phx-value="true"
      >
        <span class="text-gray-500 text-xs">
          <%= if assigns.pid, do: "Stop", else: "Talk" %>
        </span>
      </button>
    </section>
    """
  end

  @impl true
  def handle_event("talk", _params, socket) do
    {:ok, pid} = Tooba.Record.demo()
    {:noreply, assign(socket, :pid, pid)}
  end

  @impl true
  def handle_event("stop", _params, socket) do
    case Membrane.Pipeline.terminate(socket.assigns.pid) do
      :ok ->
        {:noreply, assign(socket, :pid, nil)}

      {:ok, _pid} ->
        {:noreply, assign(socket, :pid, nil)}

      {:error, _} ->
        raise "Error stopping pipeline"
    end
  end
end
