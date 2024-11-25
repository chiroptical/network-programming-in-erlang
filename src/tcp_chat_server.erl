-module(tcp_chat_server).

-export([
    infinity_to_hex/0,
    infinity_from_hex/0,
    one/0,
    message_to_binary/1
]).

infinity_to_hex() ->
    binary:encode_hex(<<"∞"/utf8>>).

one() ->
    OneInHex = list_to_integer("01", 16),
    binary:encode_hex(OneInHex).

infinity_from_hex() ->
    Hex = ["E2", "88", "9E"],
    ToBinary = <<<<(list_to_integer(H, 16))>> || H <- Hex>>,
    io:format("~ts~n", [ToBinary]).

-record(register, {contents :: nonempty_bitstring()}).

-record(broadcast, {from_username :: nonempty_bitstring(), contents :: nonempty_bitstring()}).

message_to_binary(#register{contents = Contents}) ->
    Type = list_to_integer("01", 16),
    Size = erlang:byte_size(Contents),
    <<Type, Size, Contents/utf8>>;
message_to_binary(#broadcast{from_username = Username, contents = Contents}) ->
    Type = list_to_integer("02", 16),
    SizeUsername = erlang:byte_size(Username),
    SizeContents = erlang:byte_size(Contents),
    <<Type, SizeUsername, Contents/utf8, SizeContents, Contents/utf8>>.
