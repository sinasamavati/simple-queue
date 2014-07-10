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
%%   j -> join
%%   r -> route
loop(Sock) ->
    receive
        {tcp, Sock, <<$j, Chan:4/binary, _/binary>>} ->
            sq_state:join_chan(Sock, Chan),
            %% gen_tcp:send(Sock, <<1>>),
            inet:setopts(Sock, [{active, once}]),
            io:format("join ~p~n", [Chan]),
            loop(Sock);
        {tcp, Sock, <<$r, Chan:4/binary, Data/binary>>} ->
            [gen_tcp:send(S, Data) || S <- sq_state:get_members(Chan)],
            inet:setopts(Sock, [{active, once}]),
            io:format("sent data to ~p~n", [Chan]),
            loop(Sock);
        {tcp_closed, Socket} ->
            io:format("socket closed!~n"),
            gen_tcp:close(Socket)
    end.
