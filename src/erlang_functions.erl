-module(erlang_functions).
-export([create_ets_table/1,
         add_subject/3,
         get_subject/2
]).

create_ets_table(TableName) ->
    try
        TableNameB = binary_to_atom(TableName),
        case ets:whereis(TableNameB) of
            undefined ->
                Tid = ets:new(TableNameB, [set, public, {read_concurrency, true}]),
                {ok, Tid};
            _ -> {error, already_exists}
        end
    catch
        _:Error -> {error, list_to_binary(io_lib:format("~p",[Error]))}
    end.
add_subject(Table, Name,  Subject) ->
    case ets:insert(Table, {Name, Subject}) of
        true -> {ok, nil};
        false -> {error, string:join(["Failed to insert", Name], " ")}
    end.

get_subject(Table, Name) ->
    case ets:lookup(Table, Name) of
        [] -> {error, "nothing found"};
        [{Name, Item}] -> {ok, Item}
    end.
