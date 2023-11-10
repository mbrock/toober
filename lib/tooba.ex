defmodule Tooba do
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
