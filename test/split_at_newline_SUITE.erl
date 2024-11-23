-module(split_at_newline_SUITE).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

all() ->
    [
        hello,
        empty,
        starts,
        ends,
        none
    ].

hello(_Config) ->
    {H, T} = split_at_newline:split(<<"hello world\nit is me\n">>),
    ?assert(H == <<"hello world">>),
    ?assert(T == <<"it is me\n">>).

empty(_Config) ->
    {H, T} = split_at_newline:split(<<>>),
    ?assert(H == <<>>),
    ?assert(T == <<>>).

starts(_Config) ->
    {H, T} = split_at_newline:split(<<"\nhello">>),
    ?assert(H == <<>>),
    ?assert(T == <<"hello">>).

ends(_Config) ->
    {H, T} = split_at_newline:split(<<"hello\n">>),
    ?assert(H == <<"hello">>),
    ?assert(T == <<>>).

none(_Config) ->
    {H, T} = split_at_newline:split(<<"hello">>),
    ?assert(H == <<"hello">>),
    ?assert(T == <<>>).

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_testcase(_Test, Config) ->
    Config.

end_per_testcase(_Test, _Config) ->
    ok.
