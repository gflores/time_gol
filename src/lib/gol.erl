-module (gol).
-compile(export_all).

iterate({Width, Height, Cells}, Steps) when (Width > 0) and (Height > 0) and (length(Cells) == Width * Height) and (Steps >= 0 )->
    iterate_aux({Width, Height, Cells}, Steps).

iterate_aux(State, 0)->
    State;
iterate_aux({Width, Height, Cells}, Steps)->
    io:format("step: '~p'~n", [Steps]),
    iterate_aux({Width, Height, Cells}, Steps - 1).

is_alive({Width, Height, Cells}, {X, Y}) when (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height) ->%and lists:nth(Y * Width + X + 1, Cells)->
    true;
is_alive(_, _) ->
    false.

is_alive_int({Width, Height, Cells}, {X, Y}) ->%when is_alive({Width, Height, Cells}, {X, Y})->
    1;
is_alive_int(_, _)->
    0.

get_neighbours_nb({Width, Height, Cells}, {X, Y}) when (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height) ->
    lists:foldl(fun({NgbrX, NgbrY}, Sum) -> is_alive_int({Width, Height, Cells}, {NgbrX, NgbrY}) + Sum end, 0, [
        {X - 1, Y - 1},{X, Y - 1},{X + 1, Y - 1},
        {X - 1, Y},{X + 1, Y},
        {X - 1, Y + 1},{X, Y + 1},{X + 1, Y + 1}
    ]).

