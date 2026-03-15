-module(myLists).
-export([contains/2, duplicateElements/1, sumFloats/1, sumFloatsTail/2]).

contains(Elem, [X | Tail]) -> Elem == X orelse contains(Elem, Tail);
contains(_, []) -> false.

duplicateElements([X | Tail]) -> [X, X] ++ duplicateElements(Tail);
duplicateElements([]) -> [].

sumFloats([X | Tail]) -> X + sumFloats(Tail);
sumFloats([]) -> 0.0.

sumFloatsTail([], Aku) -> Aku;
sumFloatsTail([X | Tail], Aku) -> sumFloatsTail(Tail, X + Aku).
    