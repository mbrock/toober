defmodule ToobaWeb.ResourceLive.Index do
  @moduledoc """
  Show a list of RDF subjects in the store as a table
  with links to the resource pages.
  """

  use ToobaWeb, :live_view
  use RDF

  @impl true
  def mount(_params, _session, socket) do
    vocab = Tooba.Graph.vocabulary_graph()

    descriptions = vocab |> RDF.Data.descriptions() |> exclude_bnodes()

    taxonomy =
      vocab
      |> Tooba.Graph.subclass_tree()
      |> Enum.filter(fn {node, _} -> node == ~I"http://www.w3.org/2002/07/owl#Thing" end)

    labels = vocab |> Tooba.Graph.label_map()

    {:ok,
     socket
     |> assign(:taxonomy, taxonomy)
     |> assign(:labels, labels)
     |> stream_configure(:descriptions, dom_id: &dom_id/1)
     |> stream(:descriptions, descriptions)}
  end

  defp exclude_bnodes(descriptions) do
    Enum.filter(descriptions, fn description ->
      case description.subject do
        %RDF.BlankNode{} -> false
        _ -> true
      end
    end)
  end

  defp dom_id(%RDF.Description{} = description) do
    dom_id(description.subject)
  end

  defp dom_id(%RDF.IRI{} = iri) do
    RDF.IRI.to_string(iri)
  end

  defp dom_id(%RDF.BlankNode{} = bnode) do
    bnode.value
  end

  defp triples_as_spo_maps(description) do
    RDF.Description.triples(description)
    |> Enum.map(fn {s, p, o} -> %{subject: s, predicate: p, object: o} end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <%= render_taxonomy_forest(assigns) %>
      </div>
      <div>
        <%= for {dom_id, description} <- @streams.descriptions do %>
          <ToobaWeb.ResourceLive.CardComponent.description
            title={dom_id}
            subject={description.subject}
            description={description}
            triples={triples_as_spo_maps(description)}
          />
        <% end %>
      </div>
    </div>
    """
  end

  def render_taxonomy_forest(assigns) do
    ~H"""
    <div>
      <%= for {node, children} <- @taxonomy do %>
        <article>
          <details open class="ml-4">
            <summary><%= render_rdf(%{resource: Map.get(assigns.labels, node, node)}) %></summary>
            <%= render_taxonomy_forest(Map.put(assigns, :taxonomy, children)) %>
          </details>
        </article>
      <% end %>
    </div>
    """
  end
end
