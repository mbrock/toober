defmodule Tooba.RDF.Store do
  @moduledoc """
  A persistent RDF graph store.
  """
  require RDF.Graph
  require Logger

  use GenServer

  @graph_file_name "graph.ttl"
  @log_file_name "graph.nt"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    with {:ok, graph1} <- load_from_file(@graph_file_name),
         {:ok, graph2} <- load_from_file(@log_file_name) do
      {:ok, RDF.Graph.add(graph2, graph1)}
    end
  end

  @impl true
  def handle_call({:know, data}, _from, graph) do
    news =
      data
      |> RDF.Graph.new()
      |> RDF.Data.statements()
      |> Enum.filter(fn fact ->
        not RDF.Data.include?(graph, fact)
      end)

    new_graph = RDF.Graph.add(graph, news)

    unless Enum.empty?(news) do
      Logger.info("New facts: #{inspect(news)}")

      Phoenix.PubSub.broadcast(
        Tooba.PubSub,
        "news",
        %{news: news, graph: new_graph}
      )
    end

    with :ok <- append_to_log(news) do
      {:reply, :ok, new_graph}
    end
  end

  @impl true
  def handle_call(:retrieve_graph, _from, graph) do
    {:reply, graph, graph}
  end

  def know!(data) do
    GenServer.call(__MODULE__, {:know, data})
  end

  def query(query) do
    graph = retrieve_graph()
    RDF.Graph.query(graph, query)
  end

  # Returns the current state of the graph.
  def retrieve_graph do
    GenServer.call(__MODULE__, :retrieve_graph)
  end

  defp append_to_log(data) do
    log_path = rdf_store_file_path(@log_file_name)
    ensure_data_dir_exists()

    File.open(log_path, [:append], fn file ->
      serialized = RDF.NTriples.write_string!(data)
      :ok = IO.binwrite(file, serialized <> "\n")
    end)

    :ok
  end

  def persist() do
    graph = retrieve_graph()

    graph_path = rdf_store_file_path(@graph_file_name)
    log_path = rdf_store_file_path(@log_file_name)

    ensure_data_dir_exists()

    with :ok <- RDF.Serialization.write_file(graph_path, graph) do
      case File.rm(log_path) do
        :ok -> :ok
        {:error, :enoent} -> :ok
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def load_from_file(name) do
    file_path = rdf_store_file_path(name)

    if File.exists?(file_path) do
      RDF.Serialization.read_file(file_path)
    else
      {:ok, RDF.Graph.new()}
    end
  end

  # Helper function to ensure the storage directory exists.
  defp ensure_data_dir_exists do
    data_home = get_xdg_data_home()
    :ok = File.mkdir_p(data_home)
  end

  # Helper function to generate file paths.
  defp rdf_store_file_path(file_name) do
    Path.join([get_xdg_data_home(), file_name])
  end

  # Returns the XDG data home path.
  def get_xdg_data_home do
    :filename.basedir(:user_data, Application.get_application(__MODULE__) |> Atom.to_string())
  end

  require RDF.Graph
  use RDF

  # Demo function to add a few cool RDF triples to the store.
  def demo do
    RDF.Graph.build do
      ~I<https://node.town/riga>
      |> a(~I<https://schema.org/City>)
    end
    |> know!()
  end
end
