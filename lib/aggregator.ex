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
      sensor_value_list: %{
        temperature_sensor: [],
        humidity_sensor: [],
        atmo_pressure_sensor: [],
        wind_speed_sensor: [],
        light_sensor: []
      },
      final_sensor_value: %{},
      forecast: final_forecast,
      forecast_list: forecast_list
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_forecast, _from, state) do
    
    sensor_value_list = state[:sensor_value_list]
    forecast_list = state[:forecast_list]
    final_forecast = most_frequent(forecast_list)
    final_sensor_value = get_average_value(sensor_value_list)

    response = %{
      final_forecast: final_forecast,
      final_sensor_value: final_sensor_value,
    }
    state = %{
      time: Time.utc_now(),
      sensor_value_list: %{
        temperature_sensor: [],
        humidity_sensor: [],
        atmo_pressure_sensor: [],
        wind_speed_sensor: [],
        light_sensor: []
      },
      final_sensor_value: %{},
      forecast: "",
      forecast_list: []
    }

    {:reply, response, state}
  end

  @impl true
  def handle_cast({:forecast, forecast, current_senors_value}, state) do
    start_time = state[:time]
    sensor_value_list = state[:sensor_value_list]
    final_sensor_value = state[:final_sensor_value]
    forecast_list = state[:forecast_list]
    final_forecast = state[:final_forecast]

    state = %{
      time: start_time,
      forecast: final_forecast,
      forecast_list: [forecast | forecast_list],
      final_sensor_value: final_sensor_value,
      sensor_value_list: add_value_in_map(sensor_value_list, current_senors_value)
    }

    {:noreply, state}
  end

  def add_value_in_map(map_of_list, map_of_values) do
    map =
      Enum.reduce(map_of_list, map_of_list, fn {k, v}, acc ->
        value = map_of_values[k]
        v = [value | v]
        Map.put(acc, k, v)
      end)

    map
  end

  def get_average_value(map_of_list) do
    avgList =
      Enum.map(map_of_list, fn {key, val} ->
        {key, [Enum.reduce(val, fn score, sum -> sum + score end) / Enum.count(val)]}
      end)

    map = Enum.into(avgList, %{})

    Enum.reduce(map, map, fn {k, v}, acc ->
      [head | _tail] = v
      Map.put(acc, k, head)
    end)
  end

  def most_frequent(list) do
    map = Enum.frequencies(list)
    map = Enum.sort(map, fn {_k, v}, {_k1, v1} -> v > v1 end)
    tuple = Enum.at(map, 0)
    list = Tuple.to_list(tuple)
    List.first(list)
  end

end
