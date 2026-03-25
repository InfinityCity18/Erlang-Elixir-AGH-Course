-module(pollution).

%A = #{ {"Crackow", {21, 37}} => [#{time => {{2026,3,25}, {20,10,31}}, type => "PM10", value => 100.0}]}

% Erlang jest językiem bez statycznego typowania, więc sprawdzanie każdej wprowadzonej zmiennej do funkcji czy jest stringiem na przykład, zrobiłoby
% ten kod absolutnie nieczytelnym, dlatego sprawdzamy tylko istnienie. 

% Funkcje pomocnicze
station_exists(StationName, Coords, Monitor) -> length(map:filter(fun({InMapStationName, InMapCoords},_) -> (InMapStationName == StationName) or (InMapCoords == Coords) end, Monitor)) > 0.

get_stationname_from_coords(Coords, Monitor) -> get_stationname_from_coords_internal(Coords, keys(Monitor)).
get_stationname_from_coords_internal(Coords, [{InMapStationName, InMapCoords} | Keys]) ->
    if 
        Coords == InMapCoords -> InMapStationName;
        true -> get_stationname_from_coords_internal(Coords, Keys)
    end;
get_stationname_from_coords_internal(_, []) -> {error, "No station with such coordinates found"}.

get_coords_from_stationname(StationName, Monitor) -> coords_from_stationname(StationName, keys(Monitor)).
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
    case not station_exists(StationName, Coords, Monitor) of
        false -> Monitor#{ {StationName, Coords} => []};
        true -> {error, "Station already in monitor"}
    end.

add_value(StationName, Time, Type, Value, Monitor) ->
    case station_exists(StationName, null, Monitor) of
        true -> 
            Coords = get_coords_from_stationname(StationName, Monitor),
            Measurement = #{time => Time, type => Type, value => Value},
            case lists:member(Measurement) of
                true -> {error, "Measurement exists"};
                false -> 
                    Data = maps:get({StationName, Coords}, Monitor),
                    Monitor#{{StationName, Coords} => Data + [Measurement]}
            end;
        false -> {error, "No such station"}
    end;
add_value({C1, C2}, Time, Type, Value, Monitor) ->
    case station_exists(null, {C1, C2}, Monitor) of
        true -> 
            StationName = get_stationname_from_coords({C1, C2}, Monitor),
            Measurement = #{time => Time, type => Type, value => Value},
            case lists:member(Measurement) of
                true -> {error, "Measurement exists"};
                false -> 
                    Data = maps:get({StationName, {C1, C2}}, Monitor),
                    Monitor#{{StationName, {C1, C2}} => Data + [Measurement]}
            end;
        false -> {error, "No such station"}
    end.

remove_value(StationName, Time, Type, Monitor) ->
    case station_exists(StationName, null, Monitor) of
        true -> 
            Coords = get_coords_from_stationname(StationName, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            NewData = lists:filter(fun(#{time := InTime, type := InType}) -> not ((InTime == Time) and (InType == Type)) end, Data),
            Monitor#{{StationName, Coords} => NewData};
        false -> {error, "No such station"}
    end;
remove_value({C1, C2}, Time, Type, Monitor) ->
    case station_exists(null, {C1, C2}, Monitor) of
        true -> 
            Coords = {C1, C2},
            StationName = get_stationname_from_coords(Coords, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
            NewData = lists:filter(fun(#{time := InTime, type := InType}) -> not ((InTime == Time) and (InType == Type)) end, Data),
            Monitor#{{StationName, Coords} => NewData};
        false -> {error, "No such station"}
    end.

get_one_value(StationName, Time, Type, Monitor) ->
    case station_exists(StationName, null, Monitor) of
        true -> 
            Coords = get_coords_from_stationname(StationName, Monitor),
            Data = maps:get({StationName, Coords}, Monitor),
        false -> {error, "No such station"}
    end.

