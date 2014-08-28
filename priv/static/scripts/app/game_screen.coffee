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
                                if self.can_modify == false
                                    return
                                self.cells[y * self.grid_width + x] = !self.cells[y * self.grid_width + x]
                                self.RefreshScreen()
                            )
                            # rect.on('mouseenter', (evt) ->
                            #     $("#container").css('cursor','pointer');
                            # )
                            # rect.on('mouseleave', (evt) ->
                            #     $("#container").css('cursor','default');
                            # )
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

            # @stage.on('mouseenter', (evt) ->
            #     $("#container").css('cursor','pointer');
            # )
            # @stage.on('mouseleave', (evt) ->
            #     $("#container").css('cursor','default');
            # )
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

        SetUniverseName: (universe_name) ->
            AngularUpdateUniverseName(universe_name)
            $("#set-new-name").hide()

        UpdateScreen: (data) ->
            if (data.relative_time_index != undefined)
                @relative_time_index = data.relative_time_index
            if (data.base_time_index != undefined)
                @base_time_index = data.base_time_index
            if (data.id != undefined)
                @worldline_origin_id = data.id
            if (data.parent_id != undefined)
                @parent_id = data.parent_id
            if (data.is_name_existing == true)
                console.log("name_existing: #{data.universe_name}")
                @universe_name = data.universe_name
                @SetUniverseName(data.universe_name)
            else
                $("#set-new-name").show()
                AngularUpdateUniverseName("")

            @BuildMap(data.width, data.height)
            if (data.cells != undefined)
                @cells = data.cells
                
            @RefreshScreen()
            console.log("screen updated: id: #{@worldline_origin_id}, parent_id: #{@parent_id}, base_time_index: #{@base_time_index}, relative_time_index: #{@relative_time_index}");

        AsyncUpdate: () ->
            url = "/world_line/get_state/#{@worldline_origin_id}/#{@game_time.getUTCFullYear()}/#{@game_time.getUTCMonth() + 1}/#{@game_time.getUTCDate()}"
            console.log("UPDATING TO: #{url}");
            self = this
            $.get(url,
                (data) ->
                    if (data.before_beginning == true)
                        console.log("before_beginning");
                        self.PressPlayPauseButton()
                        $(".button_backward").hide()
                        $("#fork-section").hide()
                    else
                        self.UpdateScreen($.extend(data))
                        $(".button_backward").show()
                        $("#fork-section").show()
            )
        RequestCurrentStateAndUpdate: () ->
            self = this
            $.get("/world_line/get_current_state",
                (data) ->
                    self.UpdateScreen($.extend(data))
            )

        Fork: () ->
            @is_paused = false
            @can_modify = false
            @time_ratio = 1
            $("#forking_control").hide()
            $("#time_flowing_control").show()
            $("body").css('cursor','default');
            $(".kineticjs-content").removeClass('green-highlight');
            $("body").removeClass('time-stopped');
            $("body").addClass('time-flowing');
            $("#fork-checkbox")[0].checked = false
            self = this
            json_data = JSON.stringify({
                parent_id: @worldline_origin_id,
#                base_time_index: @base_time_index + @relative_time_index,
                width: @grid_width,
                height: @grid_height,
                cells: @cells,
                year: @game_time.getUTCFullYear(),
                month: @game_time.getUTCMonth() + 1,
                day: @game_time.getUTCDate()
            })
            console.log("json_data: #{json_data}");
            $.post("/world_line/fork", {
                json_data: json_data
                },
                (resp_data) ->
                    console.log("receive: #{JSON.stringify(resp_data)}");
                    self.UpdateScreen($.extend(resp_data))
            );
        UploadName: ()->
            json_data = JSON.stringify({
                id: @worldline_origin_id,
                name: $("#input-name")[0].value
            })
            @SetUniverseName($("#input-name")[0].value)
            $("#input-name")[0].value = ""
            $.post("/world_line/set_name", {
                json_data: json_data
                }
            )
            
        UpdateTime: (delta_time) ->
            if (@is_paused == true)
                return
            prev_date = @game_time.getUTCDate()
            @game_time.setTime(@game_time.getTime() + (delta_time * @time_ratio))
            @UpdateTimeString()
            if (@game_time.getUTCDate() != prev_date)
                @AsyncUpdate()
                if ($("#fork-checkbox")[0].checked and @time_ratio > 0)
                    @is_paused = true
                    @can_modify = true
                    $("#forking_control").show()
                    $("#time_flowing_control").hide()
                    $("body").css('cursor','crosshair');
                    $(".kineticjs-content").addClass('green-highlight');
                    $("body").addClass('time-stopped');
                    $("body").removeClass('time-flowing');
        PressPlayPauseButton: ()->
            if (@time_ratio == 0)
                $("#play-button").hide()
                $("#pause-button").show()
                @time_ratio = 1
            else
                $("#pause-button").hide()
                $("#play-button").show()
                @time_ratio = 0
        SetTimeRatio: (ratio) ->            
            @time_ratio = ratio
            if (@time_ratio == 0)
                $("#pause-button").hide()
                $("#play-button").show()
            else
                $("#play-button").hide()
                $("#pause-button").show()


        UpdateTimeString: () ->
            AngularUpdateDate(@game_time.toUTCString())


    current = new GameScreen()
    current.time_ratio = 1
    current.is_paused = false
    current.can_modify = false
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
