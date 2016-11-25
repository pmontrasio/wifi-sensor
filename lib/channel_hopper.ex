defmodule ChannelHopper do

  def start_link(interface, channel_number, channel_limit, pause_milliseconds) do
    Task.start_link(fn -> hop(interface, channel_number, channel_limit, pause_milliseconds) end)
  end

  def hop(interface, channel_number, channel_limit, pause_milliseconds) do
    IO.puts "Entering channel #{channel_number}..."
    {:ok, _} = :wierl_config.param(interface, {:freq, channel_number})
    :timer.sleep(pause_milliseconds)
    next_channel_number = if (channel_number == channel_limit), do: 1, else: channel_number + 1
    hop(interface, next_channel_number, channel_limit, pause_milliseconds)
  end

end
