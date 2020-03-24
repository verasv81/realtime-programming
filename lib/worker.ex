defmodule ForecastWorker do
  use GenServer, restart: :transient

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  @impl true
  def init(msg) do
    {:ok, msg}
  end

  @impl true
  def handle_cast({:compute, msg, aggregator_pid}, states) do
    data = json_parse(msg)
    data = calc_avg(data)
    frc = forecast(data)
    GenServer.cast(aggregator_pid, {:forecast, frc})
    {:noreply, []}
  end

  def json_parse(msg) do
    msg_data = Poison.decode!(msg.data)
    msg_data["message"]
  end

  defp calc_avg(data) do
    atmo_pressure_sensor_1 = data["atmo_pressure_sensor_1"]
    atmo_pressure_sensor_2 = data["atmo_pressure_sensor_2"]
    atmo_pressure_sensor = avg(atmo_pressure_sensor_1, atmo_pressure_sensor_2)
    humidity_sensor_1 = data["humidity_sensor_1"]
    humidity_sensor_2 = data["humidity_sensor_2"]
    humidity_sensor = avg(humidity_sensor_1, humidity_sensor_2)
    light_sensor_1 = data["light_sensor_1"]
    light_sensor_2 = data["light_sensor_2"]
    light_sensor = avg(light_sensor_1, light_sensor_2)
    temperature_sensor_1 = data["temperature_sensor_1"]
    temperature_sensor_2 = data["temperature_sensor_2"]
    temperature_sensor = avg(temperature_sensor_1, temperature_sensor_2)
    wind_speed_sensor_1 = data["wind_speed_sensor_1"]
    wind_speed_sensor_2 = data["wind_speed_sensor_2"]
    wind_speed_sensor = avg(wind_speed_sensor_1, wind_speed_sensor_2)
    unix_timestamp_us = data["unix_timestamp_us"]

    map = %{
      :atmo_pressure_sensor => atmo_pressure_sensor,
      :humidity_sensor => humidity_sensor,
      :light_sensor => light_sensor,
      :temperature_sensor => temperature_sensor,
      :wind_speed_sensor => wind_speed_sensor,
      :unix_timestamp_us => unix_timestamp_us
    }

    map
  end

  defp forecast(data) do
    timestamp = data[:unix_timestamp_us] |> DateTime.from_unix(:microsecond) |> elem(1)
    cond do
      data[:temperature_sensor] < -2 && data[:light_sensor] < 128 &&
          data[:atmo_pressure_sensor] < 720 ->
        "Weather forecast for #{timestamp}: SNOW"

      data[:temperature_sensor] < -2 && data[:light_sensor] > 128 &&
          data[:atmo_pressure_sensor] < 680 ->
        "Weather forecast for #{timestamp}: WET_SNOW"

      data[:temperature_sensor] < -8 ->
        "Weather forecast for #{timestamp}:SNOW"

      data[:temperature_sensor] < -15 && data[:wind_speed_sensor] > 45 ->
        "Weather forecast for #{timestamp}:BLIZZARD"

      data[:temperature_sensor] > 0 && data[:atmo_pressure_sensor] < 710 &&
        data[:humidity_sensor] > 70 &&
          data[:wind_speed_sensor] < 20 ->
        "Weather forecast for #{timestamp}:SLIGHT_RAIN"

      data[:temperature_sensor] > 0 && data[:atmo_pressure_sensor] < 690 &&
        data[:humidity_sensor] > 70 &&
          data[:wind_speed_sensor] > 20 ->
        "Weather forecast for #{timestamp}: HEAVY_RAIN"

      data[:temperature_sensor] > 30 && data[:atmo_pressure_sensor] < 770 &&
        data[:humidity_sensor] > 80 &&
          data[:light_sensor] > 192 ->
        "Weather forecast for #{timestamp}: HOT"

      data[:temperature_sensor] > 30 && data[:atmo_pressure_sensor] < 770 &&
        data[:humidity_sensor] > 50 &&
        data[:light_sensor] > 192 && data[:wind_speed_sensor] > 35 ->
        "Weather forecast for #{timestamp}: CONVECTION_OVEN"

      data[:temperature_sensor] > 25 && data[:atmo_pressure_sensor] < 750 &&
        data[:humidity_sensor] > 70 &&
        data[:light_sensor] < 192 && data[:wind_speed_sensor] < 10 ->
        "Weather forecast for #{timestamp}: CONVECTION_OVEN"

      data[:temperature_sensor] > 25 && data[:atmo_pressure_sensor] < 750 &&
        data[:humidity_sensor] > 70 &&
        data[:light_sensor] < 192 && data[:wind_speed_sensor] > 10 ->
        "Weather forecast for #{timestamp}: SLIGHT_BREEZE"

      data[:light_sensor] < 128 ->
        "Weather forecast for #{timestamp}: CLOUDY"

      data[:temperature_sensor] > 30 && data[:atmo_pressure_sensor] < 660 &&
        data[:humidity_sensor] > 85 &&
          data[:wind_speed_sensor] > 45 ->
        "Weather forecast for #{timestamp}: MONSOON"

      true ->
        "Weather forecast for #{timestamp}: JUST_A_NORMAL_DAY"
    end
  end

  defp avg(a, b) do
    a + b / 2
  end
end
