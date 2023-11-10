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
    RDF.IRI.to_string(description.subject) |> :erlang.phash2() |> Integer.to_string()
  end

  defp render_iri(iri) when is_struct(iri, RDF.IRI) do
    RDF.IRI.to_string(iri)
  end
  defp render_iri(value), do: value

  @impl true
  def render(assigns) do
    # Let's render a definition list for each subject.
    ~H"""
    <div>
      <%= for {dom_id, description} <- @streams.descriptions do %>
        <article id={dom_id}>
          <table>
            <thead>
              <tr>
                <th>Subject</th>
                <th>Predicate</th>
                <th>Object</th>
              </tr>
            </thead>
            <tbody>
              <%= for {subject, predicate, object} <- RDF.Description.triples(description) do %>
                <tr>
                  <td><%= render_iri(subject) %></td>
                  <td><%= render_iri(predicate) %></td>
                  <td><%= render_iri(object) %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </article>
      <% end %>
    </div>
    """
  end
end
