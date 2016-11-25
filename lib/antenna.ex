defmodule Antenna do

  def enter_monitor_mode(interface) do
    :ok = :wierl_config.down(interface)
    {:ok, channel_def} = :wierl_config.param(interface, {:mode, :wierl.mode(:monitor)})
    {:channel, channel_number} = :wierl.decode({:channel, channel_def})
    :ok = :wierl_config.up(interface)
    {:ok, channel_number}
  end

  def leave_monitor_mode(interface) do
    :ok = :wierl_config.down(interface)
    {:ok, _} = :wierl_config.param(interface, {:mode, :wierl.mode(:infra)})
    :ok = :wierl_config.up(interface)
  end

end

