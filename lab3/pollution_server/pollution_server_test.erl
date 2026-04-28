%%%-------------------------------------------------------------------
%%% Fixed EUnit tests for pollution_server
%%%-------------------------------------------------------------------
-module(pollution_server_test).

-include_lib("eunit/include/eunit.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Safe setup / cleanup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setup() ->
    case whereis(pollution_server) of
        undefined -> ok;
        Pid ->
            exit(Pid, kill),
            timer:sleep(50)
    end,
    pollution_server:start(),
    ok.

cleanup(_) ->
    case whereis(pollution_server) of
        undefined -> ok;
        _ -> pollution_server:stop()
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
create_monitor_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(_) ->
         ?_assert(is_pid(whereis(pollution_server)))
     end}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_station_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(_) ->
         [
          ?_assertEqual({ok},
             pollution_server:add_station_s("Stacja 1", {1,1})),

          ?_assertMatch({error,_},
             pollution_server:add_station_s("Stacja 1", {1,1})),

          ?_assertMatch({error,_},
             pollution_server:add_station_s("Stacja 2", {1,1}))
         ]
     end}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
add_value_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(_) ->
         pollution_server:add_station_s("Stacja 1", {1,1}),
         Time = calendar:local_time(),

         [
          ?_assertEqual({ok},
             pollution_server:add_value_s("Stacja 1", Time, "PM10", 46.3)),

          ?_assertEqual({value,46.3},
             pollution_server:get_one_value_s("Stacja 1", Time, "PM10"))
         ]
     end}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
remove_value_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(_) ->
         pollution_server:add_station_s("Stacja 1", {1,1}),
         Time = calendar:local_time(),
         pollution_server:add_value_s("Stacja 1", Time, "PM10", 46.3),

         [
          ?_assertEqual({ok},
             pollution_server:remove_value_s("Stacja 1", Time, "PM10")),

          ?_assertMatch({error,_},
             pollution_server:get_one_value_s("Stacja 1", Time, "PM10"))
         ]
     end}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_station_min_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(_) ->
         pollution_server:add_station_s("Stacja 1", {1,1}),

         pollution_server:add_value_s("Stacja 1",
             {{2023,3,27},{11,0,0}}, "PM10", 10),

         pollution_server:add_value_s("Stacja 1",
             {{2023,3,27},{12,0,0}}, "PM10", 20),

         ?_assertEqual({value,10},
             pollution_server:get_station_min_s("Stacja 1", "PM10"))
     end}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_daily_mean_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(_) ->
         pollution_server:add_station_s("Stacja 1", {1,1}),
         pollution_server:add_station_s("Stacja 2", {2,2}),

         pollution_server:add_value_s("Stacja 1",
             {{2023,3,27},{11,0,0}}, "PM10", 10),

         pollution_server:add_value_s("Stacja 2",
             {{2023,3,27},{12,0,0}}, "PM10", 20),

         ?_assertEqual({value,15.0},
             pollution_server:get_daily_mean_s("PM10", {2023,3,27}))
     end}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_moving_mean_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     fun(_) ->
         pollution_server:add_station_s("Stacja 1", {1,1}),

         BaseTime   = {{2026,3,26},{12,0,0}},
         OneHourAgo = {{2026,3,26},{11,0,0}},
         TwoHoursAgo= {{2026,3,26},{10,0,0}},

         pollution_server:add_value_s("Stacja 1", OneHourAgo, "PM10", 10),
         pollution_server:add_value_s("Stacja 1", TwoHoursAgo, "PM10", 20),

         Expected = (23*10 + 22*20) / (23 + 22),

         ?_assertEqual({value,Expected},
             pollution_server:get_moving_mean_s({1,1}, "PM10", BaseTime))
     end}.