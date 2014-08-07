define(["cs!app/Funcs/json_func"], (json_func) ->
    screen_dimension_width = 600
    screen_dimension_height = 400



    class GameScreen
        InitAll: () ->
            @stage = new Kinetic.Stage({
                container: 'container',
                width: screen_dimension_width,
                height: screen_dimension_height
            })
        BuildMap: (grid_width, grid_height) ->
            if @grid_width == grid_width and @grid_height == grid_height
                return
            console.log("BUILDING MAP !");

            self = this
            @grid_width = grid_width
            @grid_height = grid_height
            cell_dimension_width = screen_dimension_width / @grid_width
            cell_dimension_height = screen_dimension_height / @grid_height
            @layerBaseCase = new Kinetic.Layer()
            @layerBioCase = new Kinetic.Layer()
            @baseCases = []
            @bioCases = []
            for y in [0..@grid_height - 1]
                for x in [0..@grid_width - 1]
                    do (x, y) ->
                        CreateCase = (rect, casesArray, layer) ->
                            casesArray.push(rect)
                            layer.add(rect)

                            rect.on('click', (evt) ->
                                self.cells[y * self.grid_width + x] = !self.cells[y * self.grid_width + x]
                                self.RefreshScreen()
                            )
                            rect.on('mouseenter', (evt) ->
                                $("#container").css('cursor','pointer');
                            )
                            rect.on('mouseleave', (evt) ->
                                $("#container").css('cursor','default');
                            )
                        baseRect = new Kinetic.Rect({
                            x: x * cell_dimension_width,
                            y: y * cell_dimension_height,
                            width: cell_dimension_width,
                            height: cell_dimension_height,
                            fill: 'grey',
                            stroke: 'black',
                            strokeWidth: 1
                        })
                        CreateCase(baseRect, self.baseCases, self.layerBaseCase)
                        bioRect = new Kinetic.Rect({
                            x: x * cell_dimension_width,
                            y: y * cell_dimension_height,
                            width: cell_dimension_width,
                            height: cell_dimension_height,
                            fill: 'red',
                            stroke: 'black',
                            strokeWidth: 1
                        })
                        bioRect.hide()
                        CreateCase(bioRect, self.bioCases, self.layerBioCase)
            @stage.add(@layerBaseCase)
            @stage.add(@layerBioCase)
        DrawBioCase: (x, y) ->
            @bioCases[y * @grid_width + x].show()
            @layerBioCase.batchDraw()
        HideBioCase: (x, y) ->
            @bioCases[y * @grid_width + x].hide()
            @layerBioCase.batchDraw()
        RefreshScreen: () ->
            for y in [0..@grid_height - 1]
                for x in [0..@grid_width - 1]
                    if (@cells[y * @grid_width + x] == true)
                        @DrawBioCase(x, y)
                    else
                        @HideBioCase(x, y)

        UpdateScreen: (data) ->
            if (data.relative_time_index != undefined)
                @relative_time_index = data.relative_time_index
            if (data.base_time_index != undefined)
                @base_time_index = data.base_time_index
            if (data.id != undefined)
                @worldline_origin_id = data.id
            if (data.parent_id != undefined)
                @parent_id = data.parent_id
            if (data.universe_name != undefined)
                AngularUpdateUniverseName(data.universe_name)
            @BuildMap(data.width, data.height)
            if (data.cells != undefined)
                @cells = data.cells
            @RefreshScreen()

        AsyncUpdate: (worldline_origin_id, relative_time_index) ->
            self = this
            $.get("/world_line/view/#{worldline_origin_id}/#{relative_time_index}",
                (data) ->
                    console.log("origin_id #{worldline_origin_id}")
                    self.UpdateScreen($.extend(data, {relative_time_index: relative_time_index}))
            )
        Fork: () ->
            self = this
            json_data = JSON.stringify({
                parent_id: @worldline_origin_id,
                base_time_index: @base_time_index + @relative_time_index,
                width: @grid_width,
                height: @grid_height,
                cells: @cells
            })
            console.log("json_data: #{json_data}");
            $.post("/world_line/fork", {
                json_data: json_data
                },
                (resp_data) ->
                    console.log("receive: #{JSON.stringify(resp_data)}");
                    self.UpdateScreen($.extend(resp_data, {relative_time_index: 0}))
            );
        UpdateTime: (delta_time) ->
            @game_time.setTime(@game_time.getTime() + (delta_time * @time_ratio))
            @UpdateTimeString()
        UpdateTimeString: () ->
            AngularUpdateDate(@game_time.toUTCString())


    current = new GameScreen()
    current.time_ratio = 1
    $.get("/world_line/view_current/",
        (data) ->
            date = data.date
            current.game_time = new Date(Date.UTC(date.year, date.month - 1, date.day, date.hour, date.minute, date.second))
            current.UpdateTimeString()
            delta_time = 100
            window.setInterval( () ->
                current.UpdateTime(delta_time)
            , delta_time);
    )
    return {current: current}
)
