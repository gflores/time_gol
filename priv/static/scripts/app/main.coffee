require(["cs!app/game_screen"], (game_screen) ->
    currentMapData = game_screen.current
    currentMapData.InitAll()
    currentMapData.RequestCurrentStateAndUpdate()
)