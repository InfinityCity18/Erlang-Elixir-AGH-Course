-module(fun_m).

Swap = fun(Letter) -> case Letter of $o -> $a; $e -> $o; _ -> Letter end end.
Swap_aoe = fun(L) -> lists:map(fun(Letter) -> case Letter of $o -> $a; $e -> $o; _ -> Letter end end, L) end.

Pred = fun(Number) -> Number rem 3 == 0 end.

Countdiv3 = fun(L) -> length(lists:filter(fun(Number) -> Number rem 3 == 0 end, L)) end.

Countdiv3_foldl = fun(L) -> lists:foldl(fun(Number, Acc) -> if ((Number rem 3) == 0) -> Acc + 1; (true) -> Acc end end, 0, L) end.

Takedata = fun(Data) -> lists:map(fun(SinglePolData) -> nth(4, SinglePolData) end, Data) end.
Fold = fun(Data) -> lists:foldl(fun(Data, Acc) -> Data ++ Acc end,[], Data) end.
Filter = fun(Data, FilterType) -> [N || {Type, N} <- Data, Type == FilterType] end.

