defmodule Aggregator do
  use GenServer, restart: :permanent

  def start_link(forecast) do
    Process.sleep(5000)
    GenServer.start_link(__MODULE__, forecast, name: __MODULE__)
  end

  @impl true
  def init(_forecast) do
    start_time = Time.utc_now()
    final_forecast = "JUST_A_NORMAL_DAY"
    forecast_list = []

    state = %{
      time: start_time,
      forecast: final_forecast,
      forecast_list: forecast_list
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_forecast, _from, state) do
    
    forecast_list = state[:forecast_list]
    final_forecast = most_frequent(forecast_list)

    response = %{
      final_forecast: final_forecast,
    }
    state = %{
      time: Time.utc_now(),
      forecast: "",
      forecast_list: []
    }

    {:reply, response, state}
  end

  @impl true
  def handle_cast({:forecast, forecast, _current_senors_value}, state) do
    start_time = state[:time]
    forecast_list = state[:forecast_list]
    final_forecast = state[:final_forecast]

    state = %{
      time: start_time,
      forecast: final_forecast,
      forecast_list: [forecast | forecast_list],
    }

    {:noreply, state}
  end

  def most_frequent(list) do
    map = Enum.frequencies(list)
    map = Enum.sort(map, fn {_k, v}, {_k1, v1} -> v > v1 end)
    tuple = Enum.at(map, 0)
    list = Tuple.to_list(tuple)
    List.first(list)
  end

end
