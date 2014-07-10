-module(sq_state).
-behaviour(gen_server).

%% -----------------------------------------------------------------------------
%% API
%% -----------------------------------------------------------------------------
-export([start_link/0]).
-export([stop/0]).
-export([insert/1]).
-export([lookup/1]).
-export([lookup/2]).
-export([join_chan/2]).
-export([get_members/1]).

%% -----------------------------------------------------------------------------
%% gen_server
%% -----------------------------------------------------------------------------
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
    gen_server:cast(?MODULE, stop).

insert(Data) ->
    gen_server:call(?MODULE, {insert, Data}).

lookup(Key) ->
    lookup(Key, undefined).

lookup(Key, Default) ->
    case ets:lookup(?MODULE, Key) of
        [] ->
            Default;
        [{_, undefined}] ->
            Default;
        [{_, V}] ->
            V
    end.

join_chan(Sock, Chan) ->
    insert({Sock, channel, Chan}).

get_members(Chan) ->
    [H] = ets:match(?MODULE, {'$1', channel, Chan}),
    [C || C <- H].

%% -----------------------------------------------------------------------------
%% gen_server
%% -----------------------------------------------------------------------------
init([]) ->
    ets:new(?MODULE, [set, named_table, protected]),
    {ok, ?MODULE}.

handle_call({insert, Arg}, _From, Tab) ->
    true = ets:insert(Tab, Arg),
    {reply, ok, Tab};
handle_call(_Msg, _From, Tab) ->
    {noreply, Tab}.

handle_cast(stop, Tab) ->
    {stop, normal, Tab};
handle_cast(_Msg, Tab) ->
    {noreply, Tab}.

handle_info(_Msg, Tab) ->
    {noreply, Tab}.

terminate(normal, _Tab) ->
    ok.

code_change(_OldVsn, Tab, _Extra) ->
    {ok, Tab}.
