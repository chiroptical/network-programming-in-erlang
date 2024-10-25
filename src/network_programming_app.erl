%%%-------------------------------------------------------------------
%% @doc network_programming public API
%% @end
%%%-------------------------------------------------------------------

-module(network_programming_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    network_programming_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
