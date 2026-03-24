-module(qs).
-export([qs/1, random_elems/3, compare_speeds/3]).

less_than(List, Arg) -> [X || X <- List, X < Arg].
grt_eq_than(List, Arg) -> [X || X <- List, X >= Arg].

qs([Pivot | Tail]) -> qs(less_than(Tail, Pivot)) ++ [Pivot] ++ qs(grt_eq_than(Tail, Pivot));
qs([]) -> [].

random_elems(N,Min,Max) -> [rand:uniform(Max - Min) || _ <- lists:seq(1,N)].

compare_speeds(List, Fun1, Fun2) -> 
    {T1,_} = timer:tc(Fun1, [List]),
    {T2,_} = timer:tc(Fun2, [List]),
    _ = io:format("Czas F1: ~p, Czas F2: ~p\n", [T1, T2]).