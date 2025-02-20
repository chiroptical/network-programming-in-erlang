-module(tcp_chat_server).

-export([
    infinity_to_hex/0,
    infinity_from_hex/0,
    one/0,
    message_to_binary/1,
    decode_message/1,
    decode_register/1
]).

infinity_to_hex() ->
    binary:encode_hex(<<"∞"/utf8>>).

one() ->
    OneInHex = integer_to_binary(list_to_integer("01", 16)),
    binary:encode_hex(OneInHex).

infinity_from_hex() ->
    Hex = ["E2", "88", "9E"],
    ToBinary = <<<<(list_to_integer(H, 16))>> || H <- Hex>>,
    io:format("~ts~n", [ToBinary]).

-record(register, {username :: nonempty_bitstring()}).

%% -record(broadcast, {from_username :: nonempty_bitstring(), contents :: nonempty_bitstring()}).

%% See https://www.erlang.org/doc/system/memory.html, use erlang:system_info(wordsize) to figure
%% out word size (i.e. small int), constrain the size to < 60 bits (i.e. small int).
message_to_binary({register, Contents}) ->
    Bin = list_to_binary(Contents),
    Size = byte_size(Bin),
    <<1, Size, Bin/binary>>;
message_to_binary({broadcast, Username, Message}) ->
    SizeUsername = byte_size(Username),
    UsernameBin = list_to_binary(Username),
    SizeMessage = byte_size(Message),
    MessageBin = list_to_binary(Message),
    <<2, SizeUsername, UsernameBin/binary, SizeMessage, MessageBin/binary>>.

decode_message(<<1, Rest/binary>>) ->
    decode_register(Rest).

% TODO: Take
decode_register(<<_Length:2, Username/binary>>) ->
    #register{username = Username}.
