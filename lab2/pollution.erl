-module(pollution).

-export([
  create_monitor/0,
  add_station/3,
  add_value/5,
  remove_value/4,
  get_one_value/4,
  get_station_min/3,
  get_daily_mean/3,
  get_moving_mean/4
]).

%A = #{ {"Crackow", {21, 37}} => [#{time => {{2026,3,25}, {20,10,31}}, type => "PM10", value => 100.0}]}

% Erlang jest językiem bez statycznego typowania, więc sprawdzanie każdej wprowadzonej zmiennej do funkcji czy jest stringiem na przykład, zrobiłoby
% ten kod absolutnie nieczytelnym, dlatego sprawdzamy tylko istnienie. 

% Funkcje pomocnicze
station_exists(StationName, Coords, Monitor) -> length(maps:keys(maps:filter(fun({InMapStationName, InMapCoords},_) -> (InMapStationName == StationName) or (InMapCoords == Coords) end, Monitor))) > 0.

get_stationname_from_coords(Coords, Monitor) -> get_stationname_from_coords_internal(Coords, maps:keys(Monitor)).
get_stationname_from_coords_internal(Coords, [{InMapStationName, InMapCoords} | Keys]) ->
    if 
        Coords == InMapCoords -> InMapStationName;
        true -> get_stationname_from_coords_internal(Coords, Keys)
    end;
get_stationname_from_coords_internal(_, []) -> {error, "No station with such coordinates found"}.

get_coords_from_stationname(StationName, Monitor) -> get_coords_from_stationname_internal(StationName, maps:keys(Monitor)).
get_coords_from_stationname_internal(StationName, [{InMapStationName, InMapCoords} | Keys]) ->
    if 
        StationName == InMapStationName -> InMapCoords;
        true -> get_coords_from_stationname_internal(StationName, Keys)
    end;
get_coords_from_stationname_internal(_, []) -> {error, "No station with such name found"}.
% Koniec funkcji pomocniczych

create_monitor() -> 
    #{}.

add_station(StationName, Coords, Monitor) -> 
    case station_exists(StationName, Coords, Monitor) of
        false -> Monitor#{ {StationName, Coords} => []};
        true -> {error, "Station already in monitor"}
    end.


add_value({C1, C2}, Time, Type, Value, Monitor) ->
    case station_exists(null, {C1, C2}, Monitor) of
        true -> 
            StationName = get_stationname_from_coords({C1, C2}, Monitor),
            Measurement = #{time => Time, type => Type, value => Value},
            Data = maps:get({StationName, {C1, C2}}, Monitor),
            case lists:member(Measurement, Data) of
                true -> {error, "Measurement exists"};
                false -> 
                    Monitor#{{StationName, {C1, C2}} => Data ++ [Measurement]}
            end;
        false -> {error, "No such station"}
    end;
add_value(StationName, Time, Type, Value, Monitor) ->
    case station_exists(StationName, null, Monitor) of
        true -> 
            Coords = get_coords_from_stationname(StationName, Monitor),
            Measurement = #{time => Time, type => Type, value => Value},
            Data = maps:get({StationName, Coords}, Monitor),
            case lists:member(Measurement, Data) of
                true -> {error, "Measurement exists"};
                false -> 
                    Monitor#{{StationName, Coords} => Data ++ [Measurement]}
            end;
        false -> {error, "No such station"}
    end.

remove_value({C1, C2}, Time, Type, Monitor) ->
    case station_exists(null, {C1, C2}, Monitor) of
        true -> 
            Coords = {C1, C2},
            StationName = get_stationname_from_coords(Coords, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            NewData = lists:filter(fun(#{time := InTime, type := InType}) -> not ((InTime == Time) and (InType == Type)) end, Data),
            if
                length(Data) == length(NewData) -> {error, "Not remove because not found"};
                true -> Monitor#{{StationName, Coords} => NewData}
            end;
        false -> {error, "No such station"}
    end;
remove_value(StationName, Time, Type, Monitor) ->
    case station_exists(StationName, null, Monitor) of
        true -> 
            Coords = get_coords_from_stationname(StationName, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            NewData = lists:filter(fun(#{time := InTime, type := InType}) -> not ((InTime == Time) and (InType == Type)) end, Data),
            if
                length(Data) == length(NewData) -> {error, "Not remove because not found"};
                true -> Monitor#{{StationName, Coords} => NewData}
            end;
        false -> {error, "No such station"}
    end.


get_one_value({C1, C2}, Time, Type, Monitor) ->
    Coords = {C1, C2},
    case station_exists(null, Coords, Monitor) of
        true -> 
            StationName = get_stationname_from_coords(Coords, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            Filtered = lists:filter(fun(#{time := InTime, type := InType}) -> ((InTime == Time) and (InType == Type)) end, Data),
            Mapped = lists:map(fun(#{value := Value}) -> Value end, Filtered),
            if
                length(Mapped) == 1 -> lists:nth(1, Mapped);
                true -> {error, "No matching measurement"}
            end;
        false -> {error, "No such station"}
    end;
get_one_value(StationName, Time, Type, Monitor) ->
    case station_exists(StationName, null, Monitor) of
        true -> 
            Coords = get_coords_from_stationname(StationName, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            Filtered = lists:filter(fun(#{time := InTime, type := InType}) -> ((InTime == Time) and (InType == Type)) end, Data),
            Mapped = lists:map(fun(#{value := Value}) -> Value end, Filtered),
            if
                length(Mapped) == 1 -> lists:nth(1, Mapped);
                true -> {error, "No matching measurement"}
            end;
        false -> {error, "No such station"}
    end.

get_station_min({C1, C2}, Type, Monitor) ->
    Coords = {C1, C2},
    case station_exists(null, Coords, Monitor) of
        true -> 
            StationName = get_stationname_from_coords(Coords, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            Filtered = lists:filter(fun(#{type := InType}) -> (InType == Type) end, Data),
            Mapped = lists:map(fun(#{value := Value}) -> Value end, Filtered),
            if
                length(Mapped) > 0 -> lists:min(Mapped);
                true -> {error, "No measurements"}
            end;
        false -> {error, "No such station"}
    end;
get_station_min(StationName, Type, Monitor) ->
    case station_exists(StationName, null, Monitor) of
        true -> 
            Coords = get_coords_from_stationname(StationName, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            Filtered = lists:filter(fun(#{type := InType}) -> (InType == Type) end, Data),
            Mapped = lists:map(fun(#{value := Value}) -> Value end, Filtered),
            if
                length(Mapped) > 0 -> lists:min(Mapped);
                true -> {error, "No measurements"}
            end;
        false -> {error, "No such station"}
    end.

get_daily_mean(Type, Day, Monitor) -> 
    StationsData = maps:values(Monitor),
    Flattened = lists:flatten(StationsData),
    Filtered = lists:filter(fun(#{type := InType, time := {InDay, _}}) -> ((InType == Type) and (InDay == Day)) end, Flattened),
    if 
        length(Filtered) == 0 -> {error, "No measurements to take mean of"};
        true ->
            Mapped = [Value || #{value := Value} <- Filtered],
            lists:sum(Mapped) / length(Mapped)
    end.

get_moving_mean(Coords, Type, Time, Monitor) ->
    case station_exists(null, Coords, Monitor) of
        true ->
            StationName = get_stationname_from_coords(Coords, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            ToGreg = [{calendar:datetime_to_gregorian_seconds(Time) - calendar:datetime_to_gregorian_seconds(InTime), Value} || #{time := InTime, value := Value, type := InType} <- Data, Type == InType ],
            FilteredGreg = lists:filter(fun({Secs, _}) -> (Secs =< (24 * 60 * 60)) end, ToGreg),
            MappedGreg = [{(24 - (Secs div (60 * 60))), Value} || {Secs, Value} <- FilteredGreg], 
            if
                length(MappedGreg) == 0 -> {error, "No measurement to take mean of"};
                true -> 
                    FracTop = lists:sum([Weight * Value || {Weight, Value} <- MappedGreg]),
                    FracBot = lists:sum([Weight || {Weight, _} <- MappedGreg]),
                    FracTop / FracBot
            end;
        false -> {error, "No such station"}
    end.
