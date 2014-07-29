-module (gol).
-compile(export_all).

iterate({Width, Height, Cells}, Steps) when (Width > 0) and (Height > 0) and (length(Cells) == Width * Height) and (Steps >= 0 )->
    iterate_aux({Width, Height, Cells}, Steps).

iterate_aux(State, 0)->
    State;
iterate_aux({Width, Height, Cells}, Steps)->
    io:format("step: '~p'~n", [Steps]),
    NewCells = compute_new_state(Width, Height, Cells),
    iterate_aux({Width, Height, NewCells}, Steps - 1).

compute_new_state(Width, Height, Cells) ->
    compute_new_state_aux([], 0, Width * Height, Width, Height, Cells).

compute_new_state_aux(NewCells, CurrentIndex, CurrentIndex, _Width, _Height, _Cells) ->
    NewCells;
compute_new_state_aux(NewCells, CurrentIndex, Length, Width, Height, Cells) ->
    compute_new_state_aux([will_be_alive({Width, Height, Cells}, math_helper:index_to_coord(Width, CurrentIndex)) | NewCells],
        CurrentIndex + 1, Length, Width, Height, Cells).


will_be_alive({Width, Height, Cells}, {X, Y}) ->
    NeighboursNb = get_neighbours_nb({Width, Height, Cells}, {X, Y}),
    case is_alive({Width, Height, Cells}, {X, Y}) of
        true -> (NeighboursNb == 2) or (NeighboursNb == 3);
        false -> (NeighboursNb == 3)
    end.



is_alive({Width, Height, Cells}, {X, Y}) when (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height) ->
    lists:nth(Y * Width + X + 1, Cells);
is_alive(_, _) ->
    false.

is_alive_int({Width, Height, Cells}, {X, Y}) ->
    case is_alive({Width, Height, Cells}, {X, Y}) of
        true -> 1;
        false -> 0
    end.

get_neighbours_nb({Width, Height, Cells}, {X, Y}) when (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height) ->
    lists:foldl(fun({NgbrX, NgbrY}, Sum) -> is_alive_int({Width, Height, Cells}, {NgbrX, NgbrY}) + Sum end, 0, [
        {X - 1, Y - 1},{X, Y - 1},{X + 1, Y - 1},
        {X - 1, Y},{X + 1, Y},
        {X - 1, Y + 1},{X, Y + 1},{X + 1, Y + 1}
    ]).

