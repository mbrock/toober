defmodule Tooba.Session.Task do
  use Task, restart: :transient

  use RDF
  alias Tooba.NS.{BFO, K}

  def start_link(_) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run() do
    session = Tooba.session()
    computer = Tooba.computer()

    Tooba.know!([
      {session, RDF.type(), K.ProgramExecution},
      {session, BFO.hasParticipant(), computer}
    ])
  end
end

defmodule Tooba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        Tooba.RDF.Store,
        Tooba.Session.Task,
        ToobaWeb.Telemetry,
        Tooba.Repo,
        {DNSCluster, query: Application.get_env(:tooba, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Tooba.PubSub},
        {Finch, name: Tooba.Finch},
        ToobaWeb.Endpoint
      ] ++
        for zigbee_enabled <- [Application.get_env(:tooba, :zigbee_enabled, true)],
            zigbee_enabled do
          {
            Tortoise.Connection,
            client_id: Tooba.Zigbee,
            handler: {Tooba.Zigbee, []},
            server: {Tortoise.Transport.Tcp, host: "localhost", port: 1883},
            subscriptions: [{"#", 0}]
          }
        end

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
