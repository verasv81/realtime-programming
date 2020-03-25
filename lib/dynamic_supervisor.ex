defmodule DynSupervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_worker(msg) do
    child_spec = %{
      id: ForecastWorker,
      start: {ForecastWorker, :start_link, [msg]},
      restart: :temporary,
      shutdown: :brutal_kill
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def remove_worker(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def calculate_and_send_forecast(pid, msg) do
    GenServer.cast(pid, {:compute, msg})
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end

  def pid_children do
    Enum.map(DynamicSupervisor.which_children(__MODULE__), fn x ->
      Enum.at(Tuple.to_list(x), 1)
    end)
  end
end
