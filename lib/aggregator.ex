defmodule Aggregator do
  use GenServer, restart: :permanent

  def start_link(forecast) do
    GenServer.start_link(__MODULE__, forecast)
  end

  @impl true
  def init(forecast) do
    {:ok, forecast}
  end

  @impl true
  def handle_cast({:forecast, forecast}, state) do
    IO.inspect(forecast)
    {:noreply, [forecast]}
  end
end
