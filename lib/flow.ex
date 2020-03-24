defmodule DataFlow do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(_msg) do
    counter = 0
    start_time = Time.utc_now()
    current_flow = 3
    state = %{counter: counter, start_time: start_time, current_flow: current_flow}
    {:ok, state}
  end

  @impl true
  def handle_call(:recommend_max_workers, _from, state) do
    {:reply, get_data_flow(state[:current_flow]), state}
  end

  @impl true
  def handle_cast(:send_flow, state) do
    counter = state[:counter]
    start_time = state[:start_time]
    current_flow = state[:current_flow]

    time_now = Time.utc_now()
    diff = Time.diff(time_now, start_time, :millisecond)

    if diff > 1000 do
      current_flow = counter
      counter = 0
      state = %{counter: counter, start_time: time_now, current_flow: current_flow}
      {:noreply, state}
    else
      counter = counter + 1
      state = %{counter: counter, start_time: start_time, current_flow: current_flow}
      {:noreply, state}
    end
  end

  def get_data_flow(head) do
    cond do
      head < 20 -> 1
      head > 20 && head < 60 -> 2
      head > 60 && head < 110 -> 3
      head > 110 && head < 160 -> 4
      head > 160 && head < 210 -> 5
      head > 210 && head < 260 -> 6
      head > 260 && head < 310 -> 7
      head > 310 && head < 360 -> 8
      head > 410 && head < 450 -> 9
      head > 450 -> 10
      true -> 10
    end
  end
end
