-module(sq_server).

%% -----------------------------------------------------------------------------
%% API
%% -----------------------------------------------------------------------------
-export([start_link/1]).

start_link(Listen) ->
    {ok, spawn_link(fun() ->
                            {ok, Sock} = gen_tcp:accept(Listen),
                            loop(Sock)
                    end)}.

%% commands:
%%   1 -> join
%%   2 -> route
%%
%% the first segment is command, the second one is channel name which should be
%%   4 bytes, the third segment is any other data
loop(Sock) ->
    receive
        {tcp, Sock, <<1, Chan:4/binary, _/binary>>} ->
            sq_state:join_chan(Sock, Chan),
            %% gen_tcp:send(Sock, <<1>>),
            inet:setopts(Sock, [{active, once}]),
            io:format("~p joined ~s~n", [Sock, Chan]),
            loop(Sock);
        {tcp, Sock, <<2, Chan:4/binary, Data/binary>>} ->
            [gen_tcp:send(S, Data) || S <- sq_state:get_members(Chan)],
            inet:setopts(Sock, [{active, once}]),
            io:format("~p sent data to the channel ~s~n", [Sock, Chan]),
            loop(Sock);
        {tcp_closed, Socket} ->
            io:format("socket closed!~n"),
            gen_tcp:close(Socket)
    end.
