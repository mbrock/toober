defmodule ToobaWeb.Live.Components.ResourceCardComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="max-w-sm rounded overflow-hidden shadow-lg">
      <div class="px-6 py-4">
        <div class="font-bold text-xl mb-2"><%= @title %></div>
        <p class="text-gray-700 text-base">
          <%= @description %>
        </p>
      </div>
      <div class="px-6 pt-4 pb-2">
        <%= for {predicate, object} <- @properties do %>
          <span class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">
            <%= predicate %>: <%= object %>
          </span>
        <% end %>
      </div>
    </div>
    """
  end
end
