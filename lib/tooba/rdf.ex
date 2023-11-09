defmodule Tooba.RDF.Store do
  @moduledoc """
  A persistent RDF graph store.
  """

  use Agent

  # Start the Agent
  @spec start_link() :: {:error, any()} | {:ok, pid()}
  def start_link do
    # The state is initialized as an empty RDF graph
    Agent.start_link(fn -> RDF.Graph.new() end, name: __MODULE__)
  end

  # Store an RDF graph in memory
  def store_graph(graph) when is_struct(graph, RDF.Graph) do
    Agent.update(__MODULE__, fn _old_graph -> graph end)
  end

  # Retrieve the RDF graph from memory
  def retrieve_graph do
    Agent.get(__MODULE__, fn graph -> graph end)
  end

  @graph_file_name "graph.ttl"
  @log_file_name "graph.log"

  defp rdf_store_file_path(file_name \\ @graph_file_name) do
    xdg_data_home =
      :filename.basedir(:user_data, Atom.to_string(Application.get_application(__MODULE__)))

    Path.join([xdg_data_home, file_name])
  end

  defp append_to_log(triples) when is_list(triples) do
    log_path = rdf_store_file_path(@log_file_name)
    :ok = File.open(log_path, [:append], fn file ->
      for triple <- triples do
        IO.write(file, RDF.NTriples.write_string!(triple))
      end
    end)
  end

  defp ensure_data_dir_exists do
    file_path = rdf_store_file_path()
    dir_path = Path.dirname(file_path)

    case File.mkdir_p(dir_path) do
      :ok -> :ok
      {:error, :eexist} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def persist(triples \\ []) do
    :ok = ensure_data_dir_exists()
    :ok = append_to_log(triples)

    if Enum.empty?(triples) do
      graph = retrieve_graph()
      file_path = rdf_store_file_path()

      {:ok, serialized} = RDF.Turtle.write_string(graph)

      File.write(file_path, serialized)
    end
  end

  def load_from_file(file_path \\ rdf_store_file_path()) do
    case File.read(file_path) do
      {:ok, contents} ->
        case RDF.Turtle.read_string(contents) do
          {:ok, graph} -> store_graph(graph)
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
