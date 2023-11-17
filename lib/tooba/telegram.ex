defmodule Tooba.Telegram do
  use Tesla
  use GenServer

  @impl true
  def init(_args) do
    {:ok, %{}}
  end
end
