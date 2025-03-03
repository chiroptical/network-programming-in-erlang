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
    Message = chat_protocol:register(~"chiroptical"),
    {ok, {register, Username}, ~""} =
        chat_protocol:decode_message(erlang:iolist_to_binary(Message)),
    ?assertEqual(~"chiroptical", Username).

broadcast_roundtrips(_Config) ->
    Contents = chat_protocol:broadcast(~"chiroptical", ~"hello world"),
    {ok, {broadcast, FromUsername, Message}, ~""} =
        chat_protocol:decode_message(erlang:iolist_to_binary(Contents)),
    ?assertEqual(~"chiroptical", FromUsername),
    ?assertEqual(~"hello world", Message).

returns_incomplete(_Config) ->
    X = chat_protocol:decode_message(<<>>),
    ?assertEqual(incomplete, X).

returns_error(_Config) ->
    Msg = list_to_binary("oh hai"),
    X = chat_protocol:decode_message(<<3, Msg/binary>>),
    ?assertEqual({error, unknown_message}, X).

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_testcase(_Test, Config) ->
    Config.

end_per_testcase(_Test, _Config) ->
    ok.
