-module (math_helper).
-compile(export_all).

index_to_coord(Width, Index) ->
    {Index rem Width, Index div Width}.
coord_to_index(Width, {X, Y}) ->
    Y * Width + X.
