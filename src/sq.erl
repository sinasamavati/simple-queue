-module(sq).

-export([start/0]).

start() ->
    application:start(sq),
    [sq_server_sup:start_socket() || _ <- lists:seq(1, 20)],
    ok.
