define([], ()->
    CreateOriginPoint = (data) ->
        $.post("/world_line/create", {
            json_data: JSON.stringify(data)
            },
            (resp_data) ->
                resp_data
        );

    return {
        CreateOriginPoint: CreateOriginPoint
    }
)