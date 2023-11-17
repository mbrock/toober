defmodule Tooba.Ontology do
  # This module works with RDF graphs that denote ontologies.
  # In particular we work with Barry Smith's BFO as an upper ontology.

  use RDF
  alias Tooba.NS.BFO

  def bfo() do
    BFO.__file__()
    |> RDF.read_file!()
  end

  def flatten_edge_tree(root) do
    # [{:a, [{:b, [{:c, []}]}]}] -> [{:a, :b}, {:b, :c}]
    Enum.flat_map(root, fn {node, children} ->
      case children do
        [] -> []
        _ -> Enum.map(children, fn {child, _} -> {node, child} end) ++ flatten_edge_tree(children)
      end
    end)
  end

  def taxonomy_graph() do
    edges =
      bfo()
      |> Tooba.Graph.subclass_relations()
      |> Tooba.Graph.forest_from_edges()
      |> Tooba.Graph.hide_bnodes()
  end

  def label_of(node, graph) do
    graph
    |> RDF.Graph.query([{node, RDF.NS.RDFS.label(), :o?}])
    |> Enum.map(fn %{o: o} -> RDF.Literal.value(o) end)
    |> List.first()
  end

  def labeled_taxonomy_edges() do
    graph = bfo()
    taxonomy = taxonomy_graph()
    edges = flatten_edge_tree(taxonomy)
    Enum.map(edges, fn {s, o} -> {label_of(s, graph), label_of(o, graph)} end)
  end

  def labeled_taxonomy_graph() do
    Graph.new() |> Graph.add_edges(labeled_taxonomy_edges())
  end
end
