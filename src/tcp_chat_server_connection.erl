-module(tcp_chat_server_connection).

-behaviour(gen_server).

-export([
    start_link/1,
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2
]).

-record(state, {socket, buffer = ~"", user_name = ~""}).

start_link(Socket) ->
    gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
    logger:notice(#{started => Socket}),
    {ok, #state{socket = Socket}}.

handle_info({tcp, Socket, Data}, State = #state{socket = Socket, buffer = Buffer}) ->
    NewState = State#state{buffer = <<Buffer/binary, Data/binary>>},
    ok = inet:setopts(Socket, [{active, once}]),
    handle_new_data(NewState);
handle_info({broadcast, UserName, Msg}, State) ->
    logger:notice(#{sending => broadcast, by => UserName, msg => Msg}),
    ok = gen_tcp:send(State#state.socket, chat_protocol:broadcast(UserName, Msg)),
    {noreply, State};
handle_info(_Msg, State) ->
    {noreply, State}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_new_data(State) ->
    case chat_protocol:decode_message(State#state.buffer) of
        {ok, Msg, Rest} ->
            NewBufferState = State#state{buffer = Rest},
            case handle_message(Msg, NewBufferState) of
                {ok, NewState} ->
                    handle_new_data(NewState);
                error ->
                    {stop, normal, NewBufferState}
            end;
        incomplete ->
            {noreply, State};
        {error, Error} ->
            logger:notice(#{invalid_data => State#state.buffer, error => Error}),
            {stop, normal, State}
    end.

handle_message({register, UserName}, State = #state{user_name = ~""}) ->
    logger:notice(#{got => register, by => UserName}),
    pg:join(broadcast, self()),
    {ok, State#state{user_name = UserName}};
handle_message({register, _}, State) ->
    logger:notice(#{invalid_register_message => State#state.user_name}),
    error;
handle_message({broadcast, UserName, _} = Broadcast, State = #state{user_name = UserName}) ->
    Processes = pg:get_members(broadcast),
    logger:notice(#{got => broadcast, by => UserName, procs => Processes}),
    lists:foreach(
        fun(Pid) ->
            Pid ! Broadcast
        end,
        Processes
    ),
    {ok, State}.
