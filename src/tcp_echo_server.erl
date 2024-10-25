-module(tcp_echo_server).

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
            logger:info(#{started => ?MODULE, listening_on => Port}),
            self() ! accept,
            {ok, Socket};
        {error, Reason} ->
            {stop, Reason}
    end.

% TODO: Page 17, handle_info
handle_info(accept, State) ->
    {noreply, State}.
