-module(time_gol_world_line_controller, [Req]).
-compile(export_all).

% main('GET', [IndexStr]) ->
%     io:format("Asking for world '~p'~n", [IndexStr]),
%     {Index, _} = string:to_integer(IndexStr),
%     [GameWorld | _] = boss_db:find(game_world, [{index, equals, Index}]),
%     {_, _, _, _, _, Cells} = GameWorld,
%     {json, [{cells, Cells}]}.

view('GET', [WorldLineOriginId]) ->
    io:format("PARAMS: WorldLineOriginId '~p'~n", [WorldLineOriginId]),
    [WorldLineOrigin | _] = boss_db:find(world_line_origin, [{id, equals, WorldLineOriginId}]),
    {world_line_origin, Id, ParentId, BaseTimeIndex, Width, Height, Cells} = WorldLineOrigin,
    {json, [{id, Id}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells}]};

view('GET', [WorldLineOriginId, TimeIndexStr]) ->
    io:format("PARAMS: WorldLineOriginId '~p', TimeIndexStr '~p' ~n", [WorldLineOriginId, TimeIndexStr]),
    {TimeIndex, _} = string:to_integer(TimeIndexStr),
    WorldLineOrigin = case boss_db:find(world_line_origin, [{id, equals, WorldLineOriginId}]) of
        [] ->
            io:format("CREATING world_line_origin~n", []),
            OriginalWidth = 40,
            OriginalHeight = 40,
            {ok, CreatedWorldLineOrigin} = (world_line_origin:new(WorldLineOriginId, no_parent, 0, OriginalWidth, OriginalHeight, [true || _ <- lists:seq(1, OriginalWidth* OriginalHeight)])):save(),
            CreatedWorldLineOrigin;
        [FoundWorldLineOrigin | _] -> FoundWorldLineOrigin
    end,
    {world_line_origin, WorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, OriginCells} = WorldLineOrigin,
    {Width, Height, Cells} = gol:iterate({Width, Height, OriginCells}, TimeIndex),
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_universal_time(erlang:now()),
    {json, [{id, WorldLineOriginId}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells}, {
        date, [{year, Year}, {month, Month}, {day, Day}, {hour, Hour}, {minute, Minute}, {second, Second}]}]}.

view_current('GET', []) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_universal_time(erlang:now()),
    {json, [{
        date, [{year, Year}, {month, Month}, {day, Day}, {hour, Hour}, {minute, Minute}, {second, Second}]}]}.

%%%%%

get_current_state('GET', []) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_universal_time(erlang:now()),
    {WorldLineOrigin, TimeIndex} = case saved_date_helper:find_world_beginning_date() of
        [] ->
            saved_date_helper:create_world_beginning_date(Year, Month, Day, 12, 0, 0),
            io:format("CREATING world_line_origin~n", []),
            OriginalWidth = 40,
            OriginalHeight = 40,
            {ok, CreatedWorldLineOrigin} = (world_line_origin:new(id, no_parent, 0, OriginalWidth, OriginalHeight, [true || _ <- lists:seq(1, OriginalWidth* OriginalHeight)])):save(),
            {world_line_origin, Id, _, _, _, _, _} = CreatedWorldLineOrigin,
            (world_line_data:new(id, Id, "Original Universe")):save(),
            {CreatedWorldLineOrigin, 0};
        [BeginningDate | _] ->
            io:format("FINDING world_line_origin~n", []),
            [FoundWorldLineOrigin | _] = world_line_helper:find_original_world_line_origin(),
            {FoundWorldLineOrigin, world_line_helper:date_to_time_index(FoundWorldLineOrigin, {{Year, Month, Day}, {Hour, Minute, Second}})}
    end,
    {world_line_origin, WorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, OriginCells} = WorldLineOrigin,
    io:format("displaying: WorldLineOriginId '~p', TimeIndex '~p' ~n", [WorldLineOriginId, TimeIndex]),
    {Width, Height, Cells} = gol:iterate({Width, Height, OriginCells}, TimeIndex),
    {IsNameExisting, Name} = case boss_db:find(world_line_data, [{origin_world_line_id, equals, WorldLineOriginId}]) of
        [] ->
            io:format("NO NAME EXISTING ~n", []),
            {false, "no_name"};
        [{world_line_data, _, WorldLineOriginId, FoundName}|_] ->
            io:format("NAME EXISTS: '~p' ~n", [FoundName]),
            {true, FoundName}
    end,

    {json, [{id, WorldLineOriginId}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells}, {
        date, [{year, Year}, {month, Month}, {day, Day}, {hour, Hour}, {minute, Minute}, {second, Second}]}, {relative_time_index, TimeIndex},
        {is_name_existing, IsNameExisting}, {universe_name, Name}]}.




get_state('GET', [WorldLineOriginId, YearStr, MonthStr, DayStr]) ->
    {Year, _} = string:to_integer(YearStr),
    {Month, _} = string:to_integer(MonthStr),
    {Day, _} = string:to_integer(DayStr),
    [FoundWorldLineOrigin | _] = boss_db:find(world_line_origin, [{id, equals, WorldLineOriginId}]),
    FoundTimeIndex = world_line_helper:date_to_time_index(FoundWorldLineOrigin, {{Year, Month, Day}, {0, 0, 0}}),


    case world_line_helper:get_valid_world_line_origin_time_index(FoundWorldLineOrigin, FoundTimeIndex) of
        {FinalWorldLineOrigin, FinalTimeIndex} ->

            {world_line_origin, FinalWorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, OriginCells} = FinalWorldLineOrigin,
            {IsNameExisting, Name} = case boss_db:find(world_line_data, [{origin_world_line_id, equals, FinalWorldLineOriginId}]) of
                [] ->
                    io:format("NO NAME EXISTING ~n", []),
                    {false, "no_name"};
                [{world_line_data, _, FinalWorldLineOriginId, FoundName}|_] ->
                    io:format("NAME EXISTS: '~p' ~n", [FoundName]),
                    {true, FoundName}
            end,
            {Width, Height, Cells} = gol:iterate({Width, Height, OriginCells}, FinalTimeIndex),
            {json, [{id, FinalWorldLineOriginId}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells},
                {relative_time_index, FinalTimeIndex}, {is_name_existing, IsNameExisting}, {universe_name, Name}]
            };
        before_beginning ->
            io:format("before_beginning~n", []),
            {json, [{before_beginning, true}]}
    end.


main('GET', []) ->
    {ok, [{cells, [true, false]}]}.

set_name('POST', []) ->
    io:format("received: '~p'~n", [mochijson:decode(Req:post_param("json_data"))]),
    {struct, [
        {"id", Id},
        {"name", Name}
        ]
    } = mochijson:decode(Req:post_param("json_data")),
    case boss_db:find(world_line_data, [{origin_world_line_id, equals, Id}]) of
        [] ->
            io:format("NEW NAME ~n", []),
            (world_line_data:new(id, Id, Name)):save();
        _ ->
            io:format("ALREADY EXISTING NAME ~n", [])
    end,
    {json, [{ok, true}]}.


fork('POST', []) ->
    % {struct, Body}= mochijson:decode(Req:request_body()),
    % ParentId = proplists:get_value(<<"parent_id">>,Body,"not_found"),
    % BaseTimeIndex = proplists:get_value(<<"base_time_index">>,Body,"not_found"),
    % Width = proplists:get_value(<<"width">>,Body,"not_found"),
    % Height = proplists:get_value(<<"height">>,Body,"not_found"),
    % Cells = [true,false],%proplists:get_value(<<"cells">>,Body,"not_found"),
    io:format("received: '~p'~n", [mochijson:decode(Req:post_param("json_data"))]),
    {struct, [
        {"parent_id", ParentId},
%        {"base_time_index", BaseTimeIndex},
        {"width", Width},
        {"height", Height},
        {"cells", {array,Cells}},
        {"year", Year},
        {"month", Month},
        {"day", Day}
        ]
    } = mochijson:decode(Req:post_param("json_data")),

    % ParentId = Req:post_param("parent_id"),
    % BaseTimeIndex = Req:post_param("base_time_index"),
    % Width = Req:post_param("width"),
    % Height = Req:post_param("height"),
    % Cells = Req:post_param("cells"),

    io:format("SEARCHING world_line_origin~n", []),
%    io:format("PARAMS: JsonData: '~p'~n", [JsonData]),
     WorldLineOrigin = case boss_db:find(world_line_origin, [{parent_id, equals, ParentId}, {cells, equals, Cells}]) of
        [] ->
            io:format("CREATING world_line_origin~n", []),
            [ParentWorldLineOrigin| _] = boss_db:find(world_line_origin, [{id, equals, ParentId}]),
            {world_line_origin, ParentId, _, ParentBaseTimeIndex, Width, Height, _} = ParentWorldLineOrigin,
            TimeIndex = world_line_helper:date_to_time_index(ParentWorldLineOrigin, {{Year, Month, Day}, {0, 0, 0}}),
            {ok, CreatedWorldLineOrigin} = (world_line_origin:new(id, ParentId, ParentBaseTimeIndex + TimeIndex, Width, Height, Cells)):save(),
            CreatedWorldLineOrigin;
        [FoundWorldLineOrigin | _] ->FoundWorldLineOrigin
    end,
    {world_line_origin, WorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, Cells} = WorldLineOrigin,
    {IsNameExisting, Name} = case boss_db:find(world_line_data, [{origin_world_line_id, equals, WorldLineOriginId}]) of
        [] ->
            io:format("NO NAME EXISTING ~n", []),
            {false, "no_name"};
        [{world_line_data, _, WorldLineOriginId, FoundName}|_] ->
            io:format("NAME EXISTS: '~p' ~n", [FoundName]),
            {true, FoundName}
    end,

%    {ok, CreatedWorldLineOrigin} = (world_line_origin:new(id, ParentId, BaseTimeIndex, Width, Height, Cells)):save(),
%    CreatedWorldLineOrigin:save(),
    {json, [{id, WorldLineOriginId}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells},
        {relative_time_index, 0}, {is_name_existing, IsNameExisting}, {universe_name, Name}]}.
