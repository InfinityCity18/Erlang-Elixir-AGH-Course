-module(concur).
-export([k_lists/0, sort_lists/1, sort_lists_proc/1, qs_proc/3]).
-import(qs, [random_elems/3, qs/1]).

k_lists() -> [random_elems(10000,1,10000) || _ <- lists:seq(1,1000)].

sort_lists([List | Lists]) -> [qs(List) | sort_lists(Lists)];
sort_lists([]) -> [].

qs_proc(List, PID, Index) ->
    PID ! {Index, qs(List)}.

sort_lists_proc(Lists) ->
    PIDs = [spawn(?MODULE, qs_proc, [List, self(), Index]) || {Index, List} <- lists:enumerate(Lists)],
    [receive {Index, List} -> List end || Index <- lists:seq(1,length(PIDs))].