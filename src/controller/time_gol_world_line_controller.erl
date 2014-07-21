-module(time_gol_world_line_controller, [Req]).
-compile(export_all).

main('GET', [IndexStr]) ->
    io:format("Asking for world '~p'~n", [IndexStr]),
    {Index, _} = string:to_integer(IndexStr),
    [GameWorld | _] = boss_db:find(game_world, [{index, equals, Index}]),
    {_, _, _, _, _, Cells} = GameWorld,
    {json, [{cells, Cells}]}.

view('GET', [WorldLineOriginId]) ->
    io:format("PARAMS: WorldLineOriginId '~p'~n", [WorldLineOriginId]),
    [WorldLineOrigin | _] = boss_db:find(world_line_origin, [{id, equals, WorldLineOriginId}]),
    {world_line_origin, Id, ParentId, BaseTimeIndex, Width, Height, Cells} = WorldLineOrigin,
    {json, [{id, Id}, {parent_id, ParentId}, {base_time_index, BaseTimeIndex}, {width, Width}, {height, Height}, {cells, Cells}]};

view('GET', [WorldLineOriginId, TimeIndexStr]) ->
    io:format("PARAMS: WorldLineOriginId '~p', TimeIndexStr '~p' ~n", [WorldLineOriginId, TimeIndexStr]),
    {TimeIndex, _} = string:to_integer(TimeIndexStr),
    [WorldLineOrigin | _] = boss_db:find(world_line_origin, [{id, equals, WorldLineOriginId}]),
    {world_line_origin, _, _, _, Width, Height, OriginCells} = WorldLineOrigin,
    {_, _, Cells} = gol:iterate({Width, Height, OriginCells}, TimeIndex),
    {json, [{cells, Cells}]}.