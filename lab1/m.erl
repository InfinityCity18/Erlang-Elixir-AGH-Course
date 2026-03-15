-module(m).          % module attribute
-export([power/2]).   % module attribute

power(A, B) ->
    math:pow(A, B).
