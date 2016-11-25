defmodule Mix.Tasks.Sensor do
  use Mix.Task

  @shortdoc "Startup the sensor"

  def run(args \\ []) do
    case length(args) do
      2 ->
        [interface, server] = args
        Sensor.run(interface, server)
      _ ->
        IO.write(:stderr, "usage: sensor interface https://server/url\n")
    end
  end
end
