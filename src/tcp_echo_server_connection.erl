-module(tcp_echo_server_connection).

-export([
    start_link/1,
    init/1,
    handle_info/2
]).

-record(state, {socket, buffer}).

start_link(Socket) ->
    gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
    {ok, #state{socket = Socket, buffer = <<>>}}.

handle_info({tcp, Socket, Data}, State = #state{socket = Socket, buffer = Buffer}) ->
    logger:notice(#{data => Data, buffer => Buffer}),
    UpdateBuffer = State#state{buffer = <<Buffer/binary, Data/binary>>},
    NewState = handle_new_data(UpdateBuffer),
    {noreply, NewState};
handle_info({tcp_error, Socket, Reason}, State = #state{socket = Socket}) ->
    logger:notice(#{tcp_connection_error => Reason}),
    {stop, normal, State};
handle_info({tcp_closed, Socket}, State = #state{socket = Socket}) ->
    {stop, normal, State}.

% Reconstructs the data at the application layer.
% An application logical package is a line terminated by newline.
handle_new_data(State = #state{socket = Socket, buffer = Buffer}) ->
    % Note: using echo will send <<"\\n">> here, use printf to get <<"\n">>!
    case split_at_newline:split(Buffer) of
        {Line, <<>>} ->
            logger:notice(#{line => Line}),
            gen_tcp:send(Socket, <<Line/binary, "\n">>),
            State#state{buffer = <<>>};
        {Line, Rest} ->
            logger:notice(#{line => Line, rest => Rest}),
            gen_tcp:send(Socket, <<Line/binary, "\n">>),
            NewState = State#state{buffer = Rest},
            handle_new_data(NewState)
    end.
