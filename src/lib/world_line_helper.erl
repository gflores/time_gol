-module (world_line_helper).
-compile(export_all).

find_original_world_line_origin() ->
    boss_db:find(world_line_origin, [{parent_id, equals, no_parent}]).

date_to_time_index(WorldLineOrigin, {Date, _Time}) ->
    {world_line_origin, WorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, OriginCells} = WorldLineOrigin,
    [{saved_date, DateId, "world_beginning", BegYear, BegMonth, BegDay, BegHour, BegMinute, BegSecond} | _] = saved_date_helper:find_world_beginning_date(),
    DaysDifference = calendar:date_to_gregorian_days(Date) - calendar:date_to_gregorian_days(BegYear, BegMonth, BegDay),
    DaysDifference - BaseTimeIndex.

time_index_to_date(WorldLineOrigin, TimeIndex) ->
    {world_line_origin, WorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, OriginCells} = WorldLineOrigin,
    [{saved_date, "world_beginning", BegYear, BegMonth, BegDay, BegHour, BegMinute, BegSecond} | _] = saved_date_helper:find_world_beginning_date(),
    DaysToAdd = TimeIndex + BaseTimeIndex,
    Seconds = calendar:datetime_to_gregorian_seconds(BegYear, BegMonth, BegDay) - 62167219200,
    {BegMegaSec, BegSec, BegMicroSec} = {Seconds div 1000000, Seconds rem 1000000, 0},
    calendar:now_to_datetime({BegMegaSec, BegSec + (DaysToAdd * 86400), BegMicroSec}).

get_valid_world_line_origin_time_index(WorldLineOrigin, TimeIndex) when TimeIndex >= 0 ->
    {WorldLineOrigin, TimeIndex};
get_valid_world_line_origin_time_index({world_line_origin, _WorldLineOriginId, no_parent, BaseTimeIndex, _, _, _}, TimeIndex) ->
    before_beginning;
get_valid_world_line_origin_time_index({world_line_origin, _WorldLineOriginId, ParentId, BaseTimeIndex, _, _, _}, TimeIndex) ->
    [ParentWorldLineOrigin | _] = boss_db:find(world_line_origin, [{id, equals, ParentId}]),
    {world_line_origin, ParentId, _, ParentBaseTimeIndex, _, _, _} = ParentWorldLineOrigin,
    get_valid_world_line_origin_time_index(ParentWorldLineOrigin, BaseTimeIndex - ParentBaseTimeIndex + TimeIndex).
