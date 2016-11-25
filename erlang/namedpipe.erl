-module(namedpipe).
-export([read/1]).

read(Pipe) ->
  Fifo = open_port(Pipe, [eof]),
  receive
    {Fifo, {data, Data}} ->
       Data
  end.

