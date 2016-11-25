defmodule DB do
  def store(server, count) do
    IO.puts("Storing #{count} to the db...")
    payload = "timestamp=#{:os.system_time(:second)}&presences=#{count}"
    HTTPoison.start
    {:ok, _} = HTTPoison.post server, payload, [{"Content-Type", "application/x-www-form-urlencoded"}]
  end
end
