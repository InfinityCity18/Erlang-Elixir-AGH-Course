-module(pollution_gen_server).

-behaviour(gen_server).

-export([start_link/0, init/1, crash/0, handle_cast/2, handle_call/3]).
-export([
    add_station/2,
    add_value/4,
    remove_value/3,
    get_one_value/3,
    get_station_min/2,
    get_daily_mean/2,
    get_moving_mean/3
]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_args) ->
    {ok, pollution:create_monitor()}.

crash() ->
    gen_server:cast(?MODULE, crash).

add_station(Name, Coords) ->
    gen_server:call(?MODULE, {add_station_msg, [Name, Coords]}).

add_value(StationName, Time, Type, Value) ->
    gen_server:call(?MODULE, {add_value_msg, [StationName, Time, Type, Value]}).

remove_value(StationName, Time, Type) ->
    gen_server:call(?MODULE, {remove_value_msg, [StationName, Time, Type]}).

get_one_value(StationName, Time, Type) ->
    gen_server:call(?MODULE, {get_one_value_msg, [StationName, Time, Type]}).

get_station_min(StationName, Type) ->
    gen_server:call(?MODULE, {get_station_min_msg, [StationName, Type]}).

get_daily_mean(Type, Day) ->
    gen_server:call(?MODULE, {get_daily_mean_msg, [Type, Day]}).

get_moving_mean(Coords, Type, Time) ->
    gen_server:call(?MODULE, {get_moving_mean_msg, [Coords, Type, Time]}).

handle_call({Req, Args0}, _From, State) ->
    Args = Args0 ++ [State],
    Result =
        case Req of
            add_station_msg ->
                {modify, apply(pollution, add_station, Args)};
            add_value_msg ->
                {modify, apply(pollution, add_value, Args)};
            remove_value_msg ->
                {modify, apply(pollution, remove_value, Args)};
            get_one_value_msg ->
                {get, apply(pollution, get_one_value, Args)};
            get_station_min_msg ->
                {get, apply(pollution, get_station_min, Args)};
            get_daily_mean_msg ->
                {get, apply(pollution, get_daily_mean, Args)};
            get_moving_mean_msg ->
                {get, apply(pollution, get_moving_mean, Args)}
        end,
    {Reply, NewState} =
        case Result of
            {get, {error, ErrorMsg}} ->
                {{error, ErrorMsg}, State};
            {get, {value, Value}} ->
                {Value, State};
            {modify, {monitor, NowyState}} ->
                {ok, NowyState};
            {modify, {error, ErrorMsg}} ->
                {{error, ErrorMsg}, State};
            _ ->
                {gowno, State}
        end,

    {reply, Reply, NewState}.

handle_cast(crash, State) ->
    1 / 0,
    {noreply, State}.
