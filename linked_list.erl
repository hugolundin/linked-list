-module(linked_list).
-export([init/0, add/2]).

chain(N, Next) ->
    receive
        {num, X} -> 
            if
                X > N ->
                    Next ! {num, X},
                    chain(N, Next);
                    
                true ->
                    New = spawn(fun () -> chain(N, Next) end),
                    chain(X, New)
            end;

        {list, From} -> 
            if
                N < infinity ->
                    Next ! {list, self()},
                    receive L -> From ! [N | L] end;

                true -> From ! [N] 
            end,
        chain(N, Next)
    end.

% Creates a linked list and returns head
init() ->
    Tail = spawn(fun () -> chain(infinity, self()) end),
    Head = spawn(fun () -> chain(0, Tail) end),
    Head.

add(List, N) -> List ! {num, N}.