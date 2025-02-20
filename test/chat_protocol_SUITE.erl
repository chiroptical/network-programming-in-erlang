-module(chat_protocol_SUITE).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

all() ->
    [
        register_roundtrips
    ].

register_roundtrips(_Config) ->
    Message = tcp_chat_server:message_to_binary({register, ~s"chiroptical"}),
    Decoded = tcp_chat_server:decode_message(Message),
    ?assert(Message =:= Decoded).

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_testcase(_Test, Config) ->
    Config.

end_per_testcase(_Test, _Config) ->
    ok.
