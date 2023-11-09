defmodule Tooba.RDF.Store do
  @moduledoc """
  A persistent RDF graph store.
  """

  use GenServer

  @graph_file_name "graph.ttl"
  @log_file_name "graph.log"

  @spec start_link() :: {:ok, pid()} | {:error, any()}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    case load_from_file() do
      {:ok, graph} -> {:ok, graph}
      {:error, _reason} -> {:ok, RDF.Graph.new()}
    end
  end

  @impl true
  def handle_call({:know, triples}, _from, graph) do
    append_to_log(triples)
    new_graph = RDF.Graph.new(triples, graph)
    {:reply, :ok, new_graph}
  end

  @impl true
  def handle_call(:retrieve_graph, _from, graph) do
    {:reply, graph, graph}
  end

  @impl true
  def handle_cast({:store, new_graph}, _graph) do
    {:noreply, new_graph}
  end

  def know!(triples) when is_list(triples) do
    GenServer.call(__MODULE__, {:know, triples})
  end

  def store_graph(graph) do
    GenServer.cast(__MODULE__, {:store, graph})
  end

  # Returns the current state of the graph.
  def retrieve_graph do
    GenServer.call(__MODULE__, :retrieve_graph)
  end

  defp append_to_log(data) do
    log_path = rdf_store_file_path(@log_file_name)

    File.open(log_path, [:append], fn {:ok, file} ->
      serialized = RDF.NTriples.write_string!(data)
      :ok = IO.binwrite(file, serialized <> "\n")
    end)

    :ok
  end

  def persist() do
    :ok = ensure_data_dir_exists()

    graph = retrieve_graph()
    serialized = RDF.Turtle.write_string!(graph)
    write_to_file(rdf_store_file_path(@graph_file_name), serialized)
  end

  # Attempts to load the graph from the storage file.
  def load_from_file do
    with {:ok, contents} <- read_from_file(rdf_store_file_path(@graph_file_name)),
         {:ok, graph} <- RDF.Turtle.read_string(contents) do
      {:ok, graph}
    else
      error -> error
    end
  end

  # Combines the persistent storage and the log file, effectively consolidating the store.
  def consolidate_log do
    log_path = rdf_store_file_path(@log_file_name)

    with {:ok, log_contents} <- read_from_file(log_path),
         {:ok, graph} <- RDF.NTriples.read_string(log_contents),
         {:ok, serialized} <- RDF.Turtle.write_string(graph) do
      write_to_file(rdf_store_file_path(@graph_file_name), serialized)
      File.rm(log_path)
    else
      error -> error
    end
  end

  # Helper function to ensure the storage directory exists.
  defp ensure_data_dir_exists do
    data_home = get_xdg_data_home()
    File.mkdir_p(data_home)
  end

  # Helper function to generate file paths.
  defp rdf_store_file_path(file_name) do
    Path.join([get_xdg_data_home(), file_name])
  end

  # Returns the XDG data home path.
  defp get_xdg_data_home do
    :filename.basedir(:user_data, Application.get_application(__MODULE__) |> Atom.to_string())
  end

  # Helper functions for file operations.
  defp read_from_file(file_path), do: File.read(file_path)
  defp write_to_file(file_path, contents), do: File.write(file_path, contents)
end
