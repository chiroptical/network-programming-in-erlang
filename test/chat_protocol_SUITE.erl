-module(chat_protocol_SUITE).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

all() ->
    [
        register_roundtrips,
        broadcast_roundtrips,
        returns_incomplete,
        returns_error
    ].

register_roundtrips(_Config) ->
    Message = tcp_chat_server:register(~"chiroptical"),
    {ok, {register, Username}, ~""} =
        tcp_chat_server:decode_message(erlang:iolist_to_binary(Message)),
    ?assertEqual(~"chiroptical", Username).

broadcast_roundtrips(_Config) ->
    Contents = tcp_chat_server:broadcast(~"chiroptical", ~"hello world"),
    {ok, {broadcast, FromUsername, Message}, ~""} =
        tcp_chat_server:decode_message(erlang:iolist_to_binary(Contents)),
    ?assertEqual(~"chiroptical", FromUsername),
    ?assertEqual(~"hello world", Message).

returns_incomplete(_Config) ->
    X = tcp_chat_server:decode_message(<<>>),
    ?assertEqual(incomplete, X).

returns_error(_Config) ->
    Msg = list_to_binary("oh hai"),
    X = tcp_chat_server:decode_message(<<3, Msg/binary>>),
    ?assertEqual({error, unknown_message}, X).

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_testcase(_Test, Config) ->
    Config.

end_per_testcase(_Test, _Config) ->
    ok.
