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
%
% Is it strange that newlines are `\` followed by `n` and
% not a newline character? Is it not possible to send `\n`
% in TCP?
handle_new_data(State = #state{socket = Socket, buffer = Buffer}) ->
    case binary:split(Buffer, [<<"\\n">>]) of
        [Line, Rest] ->
            gen_tcp:send(Socket, <<Line/binary, "\n">>),
            NewState = State#state{buffer = Rest},
            handle_new_data(NewState);
        % Either the string is empty or does not contain a newline yet.
        % This can happen if the OS buffers, e.g. `hello\nwor` and then `ld\n`.
        _Other ->
            State
    end.
