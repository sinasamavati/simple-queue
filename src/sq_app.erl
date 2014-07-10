-module(sq_app).
-behaviour(application).

%% -----------------------------------------------------------------------------
%% application callbacks
%% -----------------------------------------------------------------------------
-export([start/2]).
-export([stop/1]).

start(_StartType, _StartArgs) ->
    sq_sup:start_link().

stop(_State) ->
    ok.
