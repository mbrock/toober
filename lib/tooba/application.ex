defmodule Tooba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    zigbee_enabled = Application.get_env(:tooba, :zigbee_enabled, true)

    children = 
      [
        ToobaWeb.Telemetry,
        Tooba.Repo,
        {DNSCluster, query: Application.get_env(:tooba, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Tooba.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: Tooba.Finch},
        # Start to serve requests, typically the last entry
        ToobaWeb.Endpoint
      ] 
      ++ 
      (if zigbee_enabled do
        [
          # Tortoise MQTT client
          {
            Tortoise.Connection,
            client_id: Tooba.Zigbee,
            handler: {Tooba.Zigbee, []},
            server: {Tortoise.Transport.Tcp, host: "localhost", port: 1883},
            subscriptions: [{"#", 0}]
          }
        ]
      else
        []
      end)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tooba.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ToobaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
