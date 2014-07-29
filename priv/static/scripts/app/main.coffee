require(["cs!app/game_screen"], (game_screen) ->
    currentMapData = game_screen.current
    currentMapData.InitAll()
    currentMapData.AsyncUpdate("world_line_origin-1", 0)
)