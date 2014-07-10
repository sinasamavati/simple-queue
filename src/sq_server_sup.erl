-module(sq_server_sup).
-behaviour(supervisor).

%% -----------------------------------------------------------------------------
%% API
%% -----------------------------------------------------------------------------
-export([start_link/0]).
-export([start_socket/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% -----------------------------------------------------------------------------
%% start a socket acceptor
%% -----------------------------------------------------------------------------
start_socket() ->
    supervisor:start_child(?MODULE, []).

%% -----------------------------------------------------------------------------
%% supervisor callback
%% -----------------------------------------------------------------------------
init([]) ->
    Port = 8765,
    IP = {0, 0, 0, 0},
    {ok, Listen} = gen_tcp:listen(Port, [binary, {active, once}, {ip, IP}]),

    {ok, {{simple_one_for_one, 60, 3600},
          [{sq_server, {sq_server, start_link, [Listen]},
            temporary, 1000, worker, [sq_server]}]
         }}.
