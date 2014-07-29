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
                                self.UpdateScreen(self.grid_width, self.grid_height, self.cells)
                                console.log("clicked x: #{x}, y: #{y}")
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
        UpdateScreen: (grid_width, grid_height, cells, worldline_origin_id, @parent_id, base_time_index, relative_time_index) ->
            @relative_time_index = relative_time_index
            @base_time_index = base_time_index
            @worldline_origin_id = worldline_origin_id
            @parent_id = parent_id
            @BuildMap(grid_width, grid_height)
            @cells = cells
            for y in [0..@grid_height - 1]
                for x in [0..@grid_width - 1]
                    if (@cells[y * @grid_width + x] == true)
                        @DrawBioCase(x, y)
                    else
                        @HideBioCase(x, y)
        AsyncUpdate: (worldline_origin_id, relative_time_index) ->
            self = this
            $.ajax("/world_line/view/#{worldline_origin_id}/#{relative_time_index}", {
                success: (data) ->
                    self.UpdateScreen(data.width, data.height, data.cells, worldline_origin_id, data.parent_id, data.base_time_index, relative_time_index)
            });
        CreateAndUploadClone: () ->
            json_func.CreateOriginPoint({
                parent_id: @worldline_origin_id,
                base_time_index: @base_time_index + @relative_time_index - 1,
                width: @width,
                height: @height,
                cells: @cells
            })

    current = new GameScreen()
    return {current: current}
)
