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

  def vocabulary_graph() do
    [NS.BFO.__file__(), NS.IAO.__file__(), NS.RO.__file__()]
    |> Enum.map(&RDF.read_file!(&1))
    |> Enum.reduce(RDF.Graph.new(), &RDF.Graph.add/2)
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
