-module(pollution_server).
-import(pollution, [
  create_monitor/0,
  add_station/3,
  add_value/5,
  remove_value/4,
  get_one_value/4,
  get_station_min/3,
  get_daily_mean/3,
  get_moving_mean/4
]).
-export([
    start/0,
    stop/0,
    add_station_s/2, 
    add_value_s/4,
    remove_value_s/3, 
    get_one_value_s/3, 
    get_station_min_s/2,
    get_daily_mean_s/2,
    get_moving_mean_s/3
]).

start() -> 
    Pid = spawn(fun init/0),
    register(pollution_server, Pid).

stop() ->
    pollution_server ! stop.

init() -> 
    Monitor = create_monitor(),
    loop(Monitor).

loop(Monitor) -> 
    receive 
        {PID, Fcn, Args} -> 
            Res = apply(Fcn, Args ++ [Monitor]),
            case Res of
                {error, Msg} -> 
                    PID ! {error, Msg},
                    loop(Monitor);
                {monitor, NewMonitor} ->
                    PID ! {ok},
                    loop(NewMonitor);
                {value, Value} ->
                    PID ! {value, Value},
                    loop(Monitor)
            end;
        stop -> ok
    end.

add_station_s(StationName, Coords) ->
    pollution_server ! {self(), fun pollution:add_station/3, [StationName, Coords]},
    receive Res -> Res end.
 
add_value_s(StationName, Time, Type, Value) ->
    pollution_server ! {self(), fun pollution:add_value/5, [StationName, Time, Type, Value]},
    receive Res -> Res end.

remove_value_s(StationNameOrCoords, Time, Type) ->
    pollution_server ! {self(), fun pollution:remove_value/4, [StationNameOrCoords, Time, Type]},
    receive Res -> Res end.

get_one_value_s(StationNameOrCoords, Time, Type) ->
    pollution_server ! {self(), fun pollution:get_one_value/4, [StationNameOrCoords, Time, Type]},
    receive Res -> Res end.

get_station_min_s(StationNameOrCoords, Type) ->
    pollution_server ! {self(), fun pollution:get_station_min/3, [StationNameOrCoords, Type]},
    receive Res -> Res end.

get_daily_mean_s(Type, Day) -> 
    pollution_server ! {self(), fun pollution:get_daily_mean/3, [Type, Day]},
    receive Res -> Res end.

get_moving_mean_s(Coords, Type, Time) ->
    pollution_server ! {self(), fun pollution:get_moving_mean/4, [Coords, Type, Time]},
    receive Res -> Res end.
