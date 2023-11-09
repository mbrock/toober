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

  def gensym(prefix \\ "https://node.town/") do
    RDF.Resource.Generator.generate(
      generator: RDF.IRI.UUID.Generator,
      prefix: prefix,
      uuid_format: :default
    )
  end
end
