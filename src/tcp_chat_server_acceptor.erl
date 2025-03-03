-module(tcp_chat_server_acceptor).

-behaviour(gen_server).

-export([
    start_link/1,
    init/1,
    handle_info/2,
    handle_call/3,
    handle_cast/2
]).

-record(state, {listen_socket, supervisor}).

start_link(Options) ->
    gen_server:start_link(?MODULE, Options, []).

init(#{port := Port, supervisor := Supervisor}) ->
    case
        gen_tcp:listen(
            Port,
            [
                binary,
                {active, once},
                {exit_on_close, false},
                {reuseaddr, true},
                {backlog, 25}
            ]
        )
    of
        {ok, Socket} ->
            self() ! accept,
            {ok, #state{listen_socket = Socket, supervisor = Supervisor}};
        {error, Reason} ->
            {stop, Reason}
    end.

handle_info(accept, State) ->
    case gen_tcp:accept(State#state.listen_socket, 2_000) of
        {ok, Socket} ->
            % TODO: Likely tcp_chat_server_connection requires some info?
            {ok, Pid} =
                chat_acceptor:start_child(State#state.supervisor, Socket),
            ok = gen_tcp:controlling_process(Socket, Pid),
            self() ! accept,
            {noreply, State};
        {error, timeout} ->
            self() ! accept,
            {noreply, State};
        {error, Reason} ->
            {stop, Reason, State}
    end.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.
