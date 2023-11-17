defmodule ToobaWeb.ResourceLive.CardComponent do
  use ToobaWeb, :html

  def description(assigns) do
    label =
      assigns.description
      |> RDF.Description.get(RDF.NS.RDFS.label(), [assigns.subject])
      |> List.first()

    assigns = Map.put(assigns, :title, label)

    ~H"""
    <div class="">
      <div class="px-6">
        <div class="font-bold text-xl"><%= render_rdf(%{resource: assigns.title}) %></div>
        <%!-- <p class="text-gray-700 text-base">
          <%= @description %>
        </p> --%>
      </div>
      <div class="px-6 pb-2 mt-4">
        <.table id="triples" rows={@triples}>
          <:col :let={triple} label="Predicate">
            <%= render_rdf(%{resource: triple.predicate}) %>
          </:col>
          <:col :let={triple} label="Object">
            <%= render_rdf(%{resource: triple.object}) %>
          </:col>
        </.table>
      </div>
    </div>
    """
  end
end
