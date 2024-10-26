-module(tcp_echo_server_acceptor).

-export([
    start_link/1,
    init/1,
    handle_info/2
]).

start_link(Options) ->
    gen_server:start_link(?MODULE, Options, []).

init(Options) ->
    Port = maps:get(port, Options),

    ListenOptions = [
        binary,
        {active, true},
        {exit_on_close, false},
        {reuseaddr, true},
        {backlog, 25}
    ],

    case gen_tcp:listen(Port, ListenOptions) of
        {ok, Socket} ->
            logger:notice(#{started => ?MODULE, listening_on => Port}),
            self() ! accept,
            {ok, Socket};
        {error, Reason} ->
            {stop, Reason}
    end.

handle_info(accept, State) ->
    case gen_tcp:accept(State, 2000) of
        {ok, Socket} ->
            {ok, Pid} = tcp_echo_server_connection:start_link(Socket),
            ok = gen_tcp:controlling_process(Socket, Pid),
            self() ! accept,
            {noreply, State};
        {error, timeout} ->
            self() ! accept,
            {noreply, State};
        {error, Reason} ->
            {stop, Reason, State}
    end.
