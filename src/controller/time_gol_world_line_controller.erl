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
            {ok, CreatedWorldLineOrigin} = (world_line_origin:new(WorldLineOriginId, no_parent, 0, 3, 3, [true, true, true, true, true, true, true, true, true])):save(),
            CreatedWorldLineOrigin;
        [FoundWorldLineOrigin | _] ->FoundWorldLineOrigin
    end,
    {world_line_origin, WorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, OriginCells} = WorldLineOrigin,
    {Width, Height, Cells} = gol:iterate({Width, Height, OriginCells}, TimeIndex),
    {{Year, Month, Day}, _} = erlang:localtime(),
    {json, [{id, WorldLineOriginId}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells}, {date, [{year, Year}, {month, Month}, {day, Day}]}]}.

main('GET', []) ->
    {ok, [{cells, [true, false]}]}.

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
        {"base_time_index", BaseTimeIndex},
        {"width", Width},
        {"height", Height},
        {"cells", {array,Cells}}]
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
            {ok, CreatedWorldLineOrigin} = (world_line_origin:new(id, ParentId, BaseTimeIndex, Width, Height, Cells)):save(),
            CreatedWorldLineOrigin;
        [FoundWorldLineOrigin | _] ->FoundWorldLineOrigin
    end,
    {world_line_origin, WorldLineOriginId, ParentId, BaseTimeIndex, Width, Height, Cells} = WorldLineOrigin,

%    {ok, CreatedWorldLineOrigin} = (world_line_origin:new(id, ParentId, BaseTimeIndex, Width, Height, Cells)):save(),
%    CreatedWorldLineOrigin:save(),
    {json, [{id, WorldLineOriginId}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells}]}.
