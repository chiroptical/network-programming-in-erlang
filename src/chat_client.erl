-module(chat_client).

-include("port.hrl").

-export([
    run/0,
    send/2,
    receive_loop/2
]).

run() ->
    {ok, Socket} = gen_tcp:connect("localhost", ?PORT, [binary, {active, once}]),
    UsernameInput = io:get_line("Enter your username: "),
    Username = list_to_binary(string:chomp(UsernameInput)),
    ok = gen_tcp:send(Socket, chat_protocol:register(Username)),
    Pid = spawn(chat_client, receive_loop, [Username, Socket]),
    gen_tcp:controlling_process(Socket, Pid),
    Pid.

send(Pid, Msg) ->
    Pid ! {message, Msg}.

receive_loop(Username, Socket) ->
    receive
        {message, Msg} ->
            Broadcast = chat_protocol:broadcast(Username, Msg),
            ok = gen_tcp:send(Socket, Broadcast),
            receive_loop(Username, Socket);
        {tcp, Socket, Data} ->
            ok = inet:setopts(Socket, [{active, once}]),
            handle_data(Data),
            receive_loop(Username, Socket);
        {tcp_closed, Socket} ->
            io:format("Server closed connection.");
        {tcp_error, Socket, Reason} ->
            io:format("Server closed connection. ~s~n", Reason)
    end.

handle_data(Data) ->
    case chat_protocol:decode_message(Data) of
        {ok, {broadcast, Username, Message}, ~""} ->
            logger:notice(#{username => Username, message => Message});
        _Other ->
            logger:notice(#{notice => ~"Unable to decode message", got => Data})
    end.
