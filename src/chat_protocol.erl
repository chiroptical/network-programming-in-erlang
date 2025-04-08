-module(chat_protocol).

-export([
    infinity_to_hex/0,
    infinity_from_hex/0,
    one/0,
    register/1,
    broadcast/2,
    decode_message/1,
    decode_register/1,
    decode_broadcast/1
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

-record(register, {username :: nonempty_binary()}).

-record(broadcast, {from_username :: nonempty_binary(), message :: nonempty_binary()}).

% [1, Size, Username] is an iodata(), which is a linked list of
% binaries, when shipping this off over gen_tcp the BEAM will
% automatically deal with this in the C fiddly bits.
-spec register(Username :: nonempty_binary()) -> iolist().
register(Username) ->
    Size = byte_size(Username),
    [1, Size, Username].

-spec broadcast(Username :: nonempty_binary(), Message :: nonempty_binary()) -> iolist().
broadcast(Username, Message) ->
    SizeUsername = byte_size(Username),
    SizeMessage = byte_size(Message),
    [2, SizeUsername, Username, SizeMessage, Message].

decode_message(<<1, Contents/binary>>) ->
    decode_register(Contents);
decode_message(<<2, Contents/binary>>) ->
    decode_broadcast(Contents);
decode_message(<<>>) ->
    incomplete;
decode_message(<<_Else/binary>>) ->
    {error, unknown_message}.

decode_register(<<Size/integer, Message/binary>>) ->
    maybe
        <<Username:Size/binary, Continue/binary>> ?= Message,
        {ok, #register{username = Username}, Continue}
    else
        _ ->
            incomplete
    end.

decode_broadcast(Contents) ->
    maybe
        <<UsernameSize/integer, UsernameAndMessage/binary>> ?= Contents,
        <<Username:UsernameSize/binary, MessageSize/integer, MessageBin/binary>> ?=
            UsernameAndMessage,
        <<Message:MessageSize/binary, Continue/binary>> ?= MessageBin,
        {ok, #broadcast{from_username = Username, message = Message}, Continue}
    else
        _ ->
            incomplete
    end.
