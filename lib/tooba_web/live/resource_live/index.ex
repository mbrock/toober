defmodule ToobaWeb.ResourceLive.Index do
  @moduledoc """
  Show a list of RDF subjects in the store as a table
  with links to the resource pages.
  """

  use ToobaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    descriptions = Tooba.graph() |> RDF.Data.descriptions()
    {:ok, stream(socket, :descriptions, descriptions, dom_id: &dom_id/1)}
  end

  defp dom_id(description) do
    RDF.IRI.to_string(description.subject) |> :erlang.phash2() |> Integer.to_string()
  end

  @impl true
  def render(assigns) do
    # Let's render a definition list for each subject.
    ~H"""
    <div>
      <%= for description <- @descriptions do %>
        <article>
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
                  <td><%= subject %></td>
                  <td><%= predicate %></td>
                  <td><%= object %></td>
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
