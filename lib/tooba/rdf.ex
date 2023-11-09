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

  # Serialize and persist the RDF graph to a file
  def persist do
    graph = retrieve_graph()
    file_path = "rdf_store.ttl"

    {:ok, serialized} = RDF.Turtle.write_string(graph)

    File.write(file_path, serialized)
  end

  # Load an RDF graph from a file (on application start or as required)
  def load_from_file(file_path \\ "rdf_store.ttl") do
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
