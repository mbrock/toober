defmodule ToobaWeb.ResourceLive.Index do
  @moduledoc """
  Show a list of RDF subjects in the store as a table
  with links to the resource pages.
  """

  use ToobaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    descriptions = Tooba.graph() |> RDF.Data.descriptions()

    {:ok,
     socket
     |> stream_configure(:descriptions, dom_id: &dom_id/1)
     |> stream(:descriptions, descriptions)}
  end

  defp dom_id(description) do
    RDF.IRI.to_string(description.subject)
  end

  defp triples_as_spo_maps(description) do
    RDF.Description.triples(description)
    |> Enum.map(fn {s, p, o} -> %{subject: s, predicate: p, object: o} end)
  end

  @impl true
  def render(assigns) do
    # Let's render a definition list for each subject.
    ~H"""
    <div>
      <%= for {dom_id, description} <- @streams.descriptions do %>
        <ToobaWeb.ResourceLive.CardComponent.description
          title={dom_id}
          triples={triples_as_spo_maps(description)}
        />
      <% end %>
    </div>
    """
  end
end
