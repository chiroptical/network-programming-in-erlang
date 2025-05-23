%%%-------------------------------------------------------------------
%% @doc network_programming top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(network_programming_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{
        strategy => one_for_all,
        intensity => 0,
        period => 1
    },
    ChildSpecs = [
        %% #{
        %%     strategy => one_for_one,
        %%     id => tcp_echo_server_acceptor_supervisor,
        %%     start => {tcp_echo_server_acceptor, start_link, [#{port => 4000}]}
        %% },
        #{
            strategy => one_for_one,
            id => broadcast_registry_pg,
            start => {pg, start_link, []}
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
