-module(tcp_chat_server_connection_tests).
-include_lib("eunit/include/eunit.hrl").

closes_with_double_register_test() ->
    {ok, _Pid} = chat_acceptor:start_link(),
    {ok, Client} = gen_tcp:connect("localhost", 5000, [binary]),
    Message = chat_protocol:register(~"chiroptical"),
    ok = gen_tcp:send(Client, Message),
    ok = gen_tcp:send(Client, Message),
    receive
        {tcp_closed, Client} ->
            ?assert(true)
    after 500 ->
        ?assert(false)
    end.
