defmodule Tooba.Graph do
  def forest_from_edges(edges) do
    edges
    |> Enum.reduce(%{}, &accumulate_edges/2)
    |> build_forest()
  end

  defp accumulate_edges({child, parent}, acc) do
    acc
    |> Map.update(parent, [child], &[child | &1])
    |> Map.put_new(child, [])
  end

  defp build_forest(map) do
    roots = find_roots(map)
    Enum.map(roots, fn root -> build_subtree(root, map) end)
  end

  defp find_roots(map) do
    map
    |> Enum.reject(fn {key, _} -> Enum.any?(map, fn {_, v} -> key in v end) end)
    |> Enum.map(fn {k, _} -> k end)
  end

  defp build_subtree(node, map) do
    children = Map.get(map, node, [])
    {node, Enum.map(children, &build_subtree(&1, map))}
  end

  def hide_bnodes(forest) do
    Enum.flat_map(forest, fn {node, children} ->
      case node do
        %RDF.BlankNode{} -> children
        _ -> [{node, hide_bnodes(children)}]
      end
    end)
  end

  use RDF
  alias Tooba.NS.{BFO, IAO, RO, OWL, K}

  def vocabulary_graph() do
    [BFO.__file__(), IAO.__file__(), RO.__file__(), OWL.__file__(), K.__file__()]
    |> Enum.map(&RDF.read_file!(&1))
    |> Enum.reduce(RDF.Graph.new(), &RDF.Graph.add/2)
  end

  def subclass_relations(graph) do
    graph
    |> RDF.Graph.query([{:s?, RDF.NS.RDFS.subClassOf(), :o?}])
    |> Enum.map(fn %{s: s, o: o} -> {s, o} end)
  end

  def subclass_tree(graph) do
    graph
    |> subclass_relations()
    |> forest_from_edges()
    |> hide_bnodes()
  end

  def label_map(graph) do
    graph
    |> RDF.Graph.query([{:s?, RDF.NS.RDFS.label(), :o?}])
    |> Enum.map(fn %{s: s, o: o} -> {s, o} end)
    |> Enum.reduce(%{}, fn {s, o}, acc -> Map.put(acc, s, o) end)
  end
end

defmodule Tooba do
  defmodule Term do
    require Logger

    def term_handler(_, "_" <> _) do
      :ignore
    end

    def term_handler(_, "erroneous") do
      {:error, "erroneous term"}
    end

    def term_handler(:resource, term) do
      {:ok, term}
    end

    def term_handler(:property, term) do
      {:ok, String.downcase(term)}
    end

    def term_handler(nil, "RO_" <> term) do
      # These are some kind of meta-properties?
      Logger.debug("Ignoring RO_#{term}")
      :ignore
    end
  end

  defmodule NS do
    use RDF.Vocabulary.Namespace

    defvocab(OWL,
      base_iri: "http://www.w3.org/2002/07/owl#",
      file: "owl.ttl"
    )

    defvocab(RO,
      base_iri: "http://www.obofoundry.org/obo/",
      file: "ro.owl.rdf",
      terms: {Tooba.Term, :term_handler}
    )

    defvocab(IAO,
      base_iri: "http://purl.obolibrary.org/obo/",
      file: "iao.owl.rdf",
      ignore: ~w[iao.owl uo.owl obi.owl pato.owl bfo.owl],
      terms: {Tooba.Term, :term_handler}
    )

    defvocab(BFO,
      base_iri: "http://purl.obolibrary.org/obo/",
      file: "bfo.owl.rdf",
      ignore: ~w[iao.owl bfo.owl],
      terms: {Tooba.Term, :term_handler}
    )

    defvocab(K,
      base_iri: "http://node.town/",
      file: "kosmos.ttl",
      terms: {Tooba.Term, :term_handler}
    )
  end

  @moduledoc """
  Tooba keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def know!(data) do
    Tooba.RDF.Store.know!(data)
  end

  def query(query) do
    Tooba.RDF.Store.query(query)
  end

  def graph() do
    Tooba.RDF.Store.retrieve_graph()
  end

  def resource(iri) do
    graph() |> RDF.Data.description(iri)
  end

  defmodule Mint do
    @alphabet ~c"ybndrfg8ejkmcpqxot1uwisza345h769"

    def mint_url do
      atom = mint_atom()
      "https://node.town/#{atom}"
    end

    defp mint_atom do
      {t, x} = mint_key()
      "#{t}/#{x}"
    end

    defp mint_key do
      t =
        DateTime.utc_now()
        |> Calendar.strftime("%Y%m%d")

      x = generate_x()
      {t, x}
    end

    defp generate_x do
      seq = Enum.map(1..10, fn _ -> :rand.uniform(32) end)
      chars = Enum.map(seq, fn index -> Enum.at(@alphabet, index - 1) end)
      List.to_string(chars)
    end
  end

  def gensym() do
    Mint.mint_url() |> RDF.IRI.new()
  end
end
