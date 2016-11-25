defmodule Sensor do

  def run(interface, server) do
    max_channel = Application.get_env(:sensor, :max_channel)
    ms_per_channel = Application.get_env(:sensor, :ms_per_channel)
    collection_period = Application.get_env(:sensor, :collection_period)
    control_pipe = Application.get_env(:sensor, :control_pipe)

    IO.puts("Setting #{interface} in monitor mode...")
    {:ok, encoded_channel_number } = Antenna.enter_monitor_mode(interface)

    {:channel, channel_number} = :wierl.decode({:freq, encoded_channel_number})
    {:ok, channel_hopper } = start_hopping_channels(interface, channel_number, max_channel, ms_per_channel)

    {:ok, mac_counter} = start_counting_mac_addresses(interface, collection_period, server)

    # Read the termination command from stdin, convenient when running interactively
    #IO.puts "Press RETURN to exit"
    #IO.read(:stdio, :line)

    # Read the termination command from a named pipe, convenient when running from an init script
    IO.puts "Send a RETURN to #{control_pipe} to exit"
    NamedPipe.read(control_pipe) # Elixir version, with Port

    # As a bonus, this how to implement that with an Erlang module
    # embedded as source code into this Elixir project
    # https://ilconnettivo.wordpress.com/2016/11/13/named-pipes-ports-and-erlang-code-in-an-elixir-project/
    # Comment out the Elixir version above and uncomment the line below.
    #:namedpipe.read(control_pipe)

    IO.puts("Stopping all tasks...")
    Process.exit(channel_hopper, :kill)
    Process.exit(mac_counter, :kill)
    Antenna.leave_monitor_mode(interface)
    IO.puts("Done")

  end

  def start_hopping_channels(interface, channel_number, channel_limit, pause_milliseconds) do
    IO.puts("Starting the channel hopper task...")
    Task.start_link fn -> ChannelHopper.hop(interface, channel_number, channel_limit, pause_milliseconds) end
  end

  def start_counting_mac_addresses(interface, collection_period, server) do
    IO.puts("Starting the mac address counter...")
    Task.start_link fn -> MacAddressCounter.count(interface, collection_period, server) end
  end

end

