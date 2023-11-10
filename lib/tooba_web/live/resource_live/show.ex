defmodule ToobaWeb.ResourceLive.Show do
  use ToobaWeb, :live_view

  @impl true
  def mount(%{"iri" => iri}, _session, socket) do
    {:ok, socket |> assign(:iri, iri)}
  end

  @impl true
  def handle_params(%{"iri" => iri}, _, socket) do
    description = Tooba.resource(iri)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:description, description)}
  end

  defp page_title(:show), do: "Show Resource"
  defp page_title(:edit), do: "Edit Resource"
  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <h1><%= @page_title %></h1>
      <p><%= @description %></p>
    </div>
    """
  end
end
