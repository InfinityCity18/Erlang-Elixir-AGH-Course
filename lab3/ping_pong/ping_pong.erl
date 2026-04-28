-module(ping_pong).
-export([
    start/0,
    stop/0,
    play/1,
    pping/1,
    ppong/1
]).

start() ->
    register(pong, spawn(?MODULE, ppong, [0])),
    register(ping, spawn(?MODULE, pping, [0])).

play(N) -> ping ! N.

stop() ->
    ping ! stop,
    pong ! stop.

pping(Suma) ->
    receive
        stop -> ok;
        N when N > 0 -> 
            io:format("Otrzymalem N = ~w, wysylam ping, suma: ~w\n", [N, Suma]),
            timer:sleep(200),
            pong ! N - 1,
            pping(N + Suma);
        0 -> io:format("Koniec ping, czekam ( N = 0 )\n"), timer:sleep(200),pping(Suma)
    after
        2000 -> stop()
    end.


ppong(Suma) ->
    receive
        stop -> ok;
        N when N > 0 ->
            io:format("Otrzymalem N = ~w, wysylam pong, suma : ~w\n", [N, Suma]),
            timer:sleep(200),
            ping ! N - 1,
            ppong(N + Suma);
        0 -> io:format("Koniec pong, czekam ( N = 0\n"), timer:sleep(200),ppong(Suma)
    end.
