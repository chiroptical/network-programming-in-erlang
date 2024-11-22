-module(integration_SUITE).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

all() ->
    [
        sends_back_recieved_data,
        handles_fragmented_data,
        handle_multiple_clients
    ].

sends_back_recieved_data(_Config) ->
    {ok, Socket} = gen_tcp:connect("localhost", 4000, [binary, {active, false}]),
    DataToSend = <<"hello world\n">>,
    ok = gen_tcp:send(Socket, DataToSend),
    {ok, Got} = gen_tcp:recv(Socket, 0, 500),
    ?assert(Got == DataToSend).

handles_fragmented_data(_Config) ->
    {ok, Socket} = gen_tcp:connect("localhost", 4000, [binary, {active, false}]),
    ok = gen_tcp:send(Socket, <<"hello">>),
    ok = gen_tcp:send(Socket, <<" world\nand one more\n">>),
    {ok, One} = gen_tcp:recv(Socket, 0, 500),
    ?assert(One == <<"hello world\n">>),
    {ok, Two} = gen_tcp:recv(Socket, 0, 500),
    ?assert(Two == <<"and one more\n">>).

handle_multiple_clients(_Config) ->
    Task = fun() ->
        {ok, Socket} = gen_tcp:connect("localhost", 4000, [binary, {active, false}]),
        DataToSend = <<"derp\n">>,
        ok = gen_tcp:send(Socket, DataToSend),
        {ok, Got} = gen_tcp:recv(Socket, 0, 500),
        ?assert(Got == DataToSend)
    end,
    Receive = fun(Ref) ->
        receive
            {_Tag, Ref, _Type, _Object, _Info} -> ok
        end
    end,
    {_, One} = spawn_monitor(Task),
    Receive(One),
    {_, Two} = spawn_monitor(Task),
    Receive(Two),
    {_, Three} = spawn_monitor(Task),
    Receive(Three),
    {_, Four} = spawn_monitor(Task),
    Receive(Four),
    {_, Five} = spawn_monitor(Task),
    Receive(Five).

init_per_suite(Config) ->
    application:ensure_all_started(network_programming),
    Config.

end_per_suite(_Config) ->
    application:stop(network_programming),
    ok.

init_per_testcase(_Test, Config) ->
    Config.

end_per_testcase(_Test, _Config) ->
    ok.
