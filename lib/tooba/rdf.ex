defmodule Tooba.RDF.Store do
  @moduledoc """
  A persistent RDF graph store.
  """

  use Agent

  @graph_file_name "graph.ttl"
  @log_file_name "graph.log"

  # Initializes and starts the Agent with an empty RDF graph.
  @spec start_link() :: {:ok, pid()} | {:error, any()}
  def start_link do
    Agent.start_link(fn -> RDF.Graph.new() end, name: __MODULE__)
  end

  # Store the given graph in memory.
  def store_graph(graph) when is_struct(graph, RDF.Graph) do
    Agent.update(__MODULE__, fn _ -> graph end)
  end

  # Retrieve the graph from memory.
  def retrieve_graph do
    Agent.get(__MODULE__, fn graph -> graph end)
  end

  # Save the given triples to the log file, creating a new entry for each.
  defp append_to_log(triples) when is_list(triples) do
    log_path = rdf_store_file_path(@log_file_name)

    File.open(log_path, [:append], fn {:ok, file} ->
      for triple <- triples do
        serialized = RDF.NTriples.write_string!(triple)
        :ok = IO.binwrite(file, serialized <> "\n")
      end
    end)

    :ok
  end

  # Persists the current state of the graph and any new triples passed as arguments.
  def persist(triples \\ []) do
    :ok = ensure_data_dir_exists()
    :ok = append_to_log(triples)

    unless Enum.empty?(triples) do
      graph = retrieve_graph()
      serialized = RDF.Turtle.write_string!(graph)
      write_to_file(rdf_store_file_path(@graph_file_name), serialized)
    else
      :ok
    end
  end

  # Attempts to load the graph from the storage file.
  def load_from_file do
    with {:ok, contents} <- read_from_file(rdf_store_file_path(@graph_file_name)),
         {:ok, graph} <- RDF.Turtle.read_string(contents) do
      store_graph(graph)
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
