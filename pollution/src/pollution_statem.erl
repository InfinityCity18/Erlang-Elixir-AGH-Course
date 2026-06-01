-module(pollution_statem).

-behaviour(gen_statem).

-export([init/1, callback_mode/0, start_link/0, store_data/0, add_value/3, set_station/1]).
-export([selecting/3, adding/3]).

start_link() ->
    gen_statem:start_link({local, ?MODULE}, ?MODULE, [], []).

set_station(NameOrCoords) ->
    case pollution_gen_server:has_station(NameOrCoords) of
        false ->
            {error, "No such station"};
        true ->
            gen_statem:call(?MODULE, {station, NameOrCoords})
    end.

add_value(DateTime, Type, Value) ->
    gen_statem:call(?MODULE, {add, DateTime, Type, Value}).

store_data() ->
    gen_statem:call(?MODULE, store).

callback_mode() -> state_functions.

init(_Args) ->
    {ok, selecting, {}}.

selecting({call, From}, {station, Station}, _Data) ->
    {next_state, adding, {Station, []}, [{reply, From, ok}]};
selecting({call, From}, _, Data) ->
    {next_state, selecting, Data, [{reply, From, {error, "No matching fun in current state"}}]}.

adding({call, From}, {add, DateTime, Type, Value}, {Station, Values}) ->
    {next_state, adding, {Station, Values ++ [{DateTime, Type, Value}]}, [{reply, From, ok}]};
adding({call, From}, store, {Station, Values}) ->
    lists:foreach(
        fun({DT, T, V}) ->
            pollution_gen_server:add_value(Station, DT, T, V)
        end,
        Values
    ),
    {next_state, selecting, {}, [{reply, From, ok}]};
adding({call, From}, _, Data) ->
    {next_state, adding, Data, [{reply, From, {error, "No matching fun in current state"}}]}.
