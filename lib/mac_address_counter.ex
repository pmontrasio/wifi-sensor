defmodule MacAddressCounter do
  def start_link(interface, period, server) do
    Task.start_link(fn -> count(interface, period, server) end)
  end

  def count(interface, period, server) do
    {:ok, epcap} = :epcap.start([{:interface, interface, :monitor, true}])
    packet_monitor_loop(epcap, %{}, :os.system_time(:millisecond) + period, period, server)
  end

  defp packet_monitor_loop(epcap, addresses, send_at, period, server) do
    receive do
      {:packet, data_link_type, _, _, packet} ->
        addresses = update(addresses, data_link_type, packet)
        now = :os.system_time(:millisecond)
        if now >= send_at do
          IO.puts("Collected addresses: #{Enum.join(Map.keys(addresses), ", ")}")
          spawn fn -> DB.store(server, length(Map.keys(addresses))) end
          packet_monitor_loop(epcap, %{}, now + period, period, server)
        else
          packet_monitor_loop(epcap, addresses, send_at, period, server)
        end

      _ -> :epcap.stop(epcap)
    end

  end

  defp update(addresses, data_link_type, packet) do
    case :pkt.decode(:pkt.dlt(data_link_type), packet) do
      {:ok, decoded_packet} ->
        {header, _} = decoded_packet
        case hd(header) do
          {:ether, source_mac_address, destination_mac_address, _, _} ->
            source = Base.encode16(source_mac_address, case: :lower)
            destination = Base.encode16(destination_mac_address, case: :lower)
            addresses
            |> Map.update(source, 1, &(&1 + 1)) # & is a lambda, &1 is the 1st arg of the lambda
            |> Map.update(destination, 1, &(&1 + 1))
          _ ->
            addresses
        end
      {:error, _, _} ->
        addresses
    end
  end



end

# Sample packets
# [{:ether, <<255, 255, 255, 255, 255, 255>>, <<156, 92, 249, 233, 22, 81>>, 2054, 0}, {:arp, 1, 2048, 6, 4, 1, <<156, 92, 249, 233, 22, 81>>, {192, 168, 1, 102}, <<0, 0, 0, 0, 0, 0>>, {192, 168, 1, 100}}, <<193, 172, 41, 253, 237, 24, 173, 65, 239, 155, 4, 178, 132, 0, 0, 0, 64, 107>>]


# :pkt.decapsulate_next({:larq, <<128, 1, 1, 21, 0, 0, 16, 24, 0, 1, 0, 2, 0, 0, 0, 0, 0, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 173, 64, 14, 133, 82, 140, 79, 119, 108, 48, 0, 0, 0, 0, 0, 0, ...>>}, [{:ether, <<184, 39, 235, 46, 32, 156>>, <<186, 39, 235, 46, 32, 156>>, 34924, 0}])

