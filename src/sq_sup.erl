-module(sq_sup).
-behaviour(supervisor).

%% -----------------------------------------------------------------------------
%% API
%% -----------------------------------------------------------------------------
-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% -----------------------------------------------------------------------------
%% supervisor callback
%% -----------------------------------------------------------------------------
init([]) ->
    {ok, {{one_for_one, 60, 3600},
          [{sq_state, {sq_state, start_link, []},
            permanent, 5000, worker, [sq_state]},
           {sq_server, {sq_server_sup, start_link, []},
            permanent, 5000, supervisor, [sq_server]}]
         }}.
