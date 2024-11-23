-module(split_at_newline).

-export([
    split/1
]).

split(Bin) ->
    split_internal(Bin, <<>>).

split_internal(<<>>, X) ->
    {X, <<>>};
split_internal(<<"\n", Rest/binary>>, X) ->
    {X, Rest};
split_internal(<<X, Rest/binary>>, Y) ->
    split_internal(Rest, <<Y/binary, X>>).
