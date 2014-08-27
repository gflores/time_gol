-module (saved_date_helper).
-compile(export_all).


find_world_beginning_date() ->
    boss_db:find(saved_date, [{name, equals, "world_beginning"}]).

create_world_beginning_date(Year, Month, Day, Hour, Minute, Second) ->
    (saved_date:new(id, "world_beginning", Year, Month, Day, Hour, Minute, Second)):save().
