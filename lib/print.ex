defmodule Print do
  def start_link do
    time_now = Time.utc_now()
    update_frequency = 1000
    forecast_pid = spawn_link(__MODULE__, :get_forecast, [time_now, update_frequency, true])
    :ets.new(:buckets_registry, [:named_table])

    :ets.insert(:buckets_registry, {"forecast_pid", forecast_pid})
    {:ok, self()}
  end

  def get_forecast(start_time, update_frequency, is_working) do
    time_now = Time.utc_now()
    date_time_now = DateTime.utc_now()
    diff = Time.diff(time_now, start_time, :millisecond)

    if diff > update_frequency && is_working === true do
      forecast = GenServer.call(Aggregator, :get_forecast)
      print(forecast, date_time_now)
      get_forecast(time_now, update_frequency, is_working)
    else
      receive do
        [is_working | update_frequency] ->
          if update_frequency < 200 do
            IO.puts("Minimum update frequency is 200")
            Process.sleep(2000)
            get_forecast(start_time, 200, is_working)
          else
            get_forecast(start_time, update_frequency, is_working)
          end
      after
        10 -> get_forecast(start_time, update_frequency, is_working)
      end
    end
  end

 

  def print(forecast, date_time_now) do
    sensor_list = forecast[:final_sensor_value]
    IO.puts("-------------------------------")
    IO.puts("Forecast for #{date_time_now.day}/#{date_time_now.month}/#{date_time_now.year} #{date_time_now.hour}:#{date_time_now.minute}")
    IO.puts("-------------------------------")    
    IO.puts("Temperature -> #{sensor_list[:temperature_sensor]}")
    IO.puts("Humidity -> #{sensor_list[:humidity_sensor]}")
    IO.puts("Pressure -> #{sensor_list[:atmo_pressure_sensor]}")
    IO.puts("Wind -> #{sensor_list[:wind_speed_sensor]}")
    IO.puts("Light -> #{sensor_list[:light_sensor]}")
    IO.puts("*******#{forecast[:final_forecast]}*******")
    IO.puts("-------------------------------")
  end
end
