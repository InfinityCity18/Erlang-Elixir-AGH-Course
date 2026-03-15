-module(kalkulator).     
-export([random_reading/0, return_matching_type/2, random_readings/1,  number_of_readings/2, calculate_min_and_max/2, calculate_mean/2]).  

random_reading() -> 
    X = ["Warszawa", "Poznan", "Kraków"], %Poznań nie wyświetla poprawnie z "ń"
    {
        lists:nth(rand:uniform(length(X)), X),
        {2026, 3, rand:uniform(31)},
        {rand:uniform(23),rand:uniform(59),rand:uniform(59)},
        [
            {"PM10", rand:uniform_real() * 100.0},
            {"PM2.5", rand:uniform_real() * 100.0},
            {"PM1", rand:uniform_real() * 100.0}
        ]
    }.

return_matching_type(Type, [{Type, Value} | _]) -> {Type, Value};
return_matching_type(Type, [{_, _} | L]) -> return_matching_type(Type, L);
return_matching_type(_, []) -> "err".  

random_readings(0) -> [];
random_readings(N) -> [random_reading() | random_readings(N - 1)].

number_of_readings([{_, Date, _, _} | Readings], Date) -> 1 + number_of_readings(Readings, Date);
number_of_readings([{_, _, _, _} | Readings], Date) -> number_of_readings(Readings, Date);
number_of_readings([], _) -> 0;
number_of_readings(_, _) -> "err".

calculate_min_and_max([{_, _, _, Types} | Readings], Type) -> 
    case return_matching_type(Type, Types) of 
        {Type, Value} -> 
            {Min, Max} = calculate_min_and_max(Readings, Type),
            {min(Min, Value), max(Max, Value)};
        _ -> {"err", "err"}
    end;
calculate_min_and_max([], _) -> {100.0, 0.0};
calculate_min_and_max(_, _) -> {"err", "err"}.

calculate_mean_internal([{_, _, _, Types} | Readings], Type, Len) -> 
    case return_matching_type(Type, Types) of
        {Type, Value} ->
            Value / Len + calculate_mean_internal(Readings, Type, Len);
        _ -> "err"
    end;
calculate_mean_internal([], _, _) -> 0.0;
calculate_mean_internal(_, _, _) -> "err".

calculate_mean(Readings, Type) -> calculate_mean_internal(Readings, Type, erlang:length(Readings)).