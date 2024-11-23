-module(split_at_newline_SUITE).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

all() ->
    [
        basic_test
    ].

basic_test(_Config) ->
    {H, T} = split_at_newline:split(<<"hello world\nit is me\n">>),
    ?assert(H == <<"hello world">>),
    ?assert(T == <<"it is me\n">>).

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_testcase(_Test, Config) ->
    Config.

end_per_testcase(_Test, _Config) ->
    ok.
