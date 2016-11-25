defmodule NamedPipe do

  def read(pipe) when is_binary(pipe) do
    read(String.to_char_list(pipe))
  end

  def read(pipe) do
    fifo = Port.open(pipe, [:eof])
    receive do
      {fifo, {:data, data}} ->
        data
    end
  end

end
