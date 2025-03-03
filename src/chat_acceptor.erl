-module(chat_acceptor).
-behaviour(supervisor).

-export([
    start_link/0,
    init/1,
    start_child/2
]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

% Given a supervisor and socket, generate a new child with a
% random identifier.
start_child(Supervisor, Socket) ->
    Id = base64:encode(crypto:strong_rand_bytes(10)),
    supervisor:start_child(
        Supervisor,
        #{
            id => Id,
            start => {tcp_chat_server_connection, start_link, [Socket]},
            restart => temporary
        }
    ).

init([]) ->
    SupFlags = #{
        strategy => one_for_all,
        intensity => 0,
        period => 1
    },
    ChildSpecs = [
        % Accepts incoming connections and passes them to
        % tcp_chat_server_connection via gen_tcp:controlling_process
        % i.e. when accepting connections, we'll start a new child
        % for tcp_chat_server_connection
        #{
            strategy => one_for_one,
            id => tcp_chat_server_acceptor_supervisor,
            start => {tcp_chat_server_acceptor, start_link, [#{port => 5000, supervisor => self()}]}
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
