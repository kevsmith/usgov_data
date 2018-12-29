Terminals

% Datatypes
text integer date

% Notation
fieldsep bol eol.

Nonterminals

line fields value.

Rootsymbol line.

line ->
    bol fields eol : compact_seps('$2').

fields ->
    fieldsep fields : [sep|'$2'].
fields ->
    value fields : ['$1'|'$2'].
fields ->
    value : ['$1'].
fields ->
    fieldsep : [sep].

value ->
    text : unwrap('$1').
value ->
    integer : unwrap('$1').
value ->
    date : unwrap('$1').

Erlang code.
-export([scan_and_parse/1]).

-spec scan_and_parse(binary()) -> {ok, [term()]} | {error, atom()}.
scan_and_parse(Text) when is_binary(Text) ->
    scan_and_parse1(binary_to_list(Text)).

scan_and_parse1(Text) ->
    case csv_lexer:string(Text) of
        {ok, Tokens, _} ->
            Tokens1 = [{bol, nil}|Tokens] ++ [{eol, nil}],
            case parse(Tokens1) of
                {ok, Fields} ->
                    {ok, Fields};
                {error, Error} ->
                    {error, Error}
            end;
        {error, Error, _} ->
            {error, list_to_binary([csv_lexer:format_error(Error), "."])}
    end.

unwrap({text, Text}) ->
    list_to_binary(Text);
unwrap({integer, I}) ->
    I;
unwrap({date, {Year, Month, Day}}) ->
    'Elixir.Date':'from_erl!'({Year, Month, Day}).

compact_seps([sep|T]) ->
    compact_seps(T, [nil]);
compact_seps([H|T]) ->
    compact_seps(T, [H]).

compact_seps([], Acc) ->
    lists:reverse(Acc);
compact_seps([sep, sep], Acc) ->
    compact_seps([], [nil, nil|Acc]);
compact_seps([sep], [nil|_]=Acc) ->
    compact_seps([], [nil, nil|Acc]);
compact_seps([sep], Acc) ->
    compact_seps([], [nil|Acc]);
compact_seps([sep, sep|T], Acc) ->
    compact_seps(T, [nil|Acc]);
compact_seps([sep|T], [nil|_]=Acc) ->
    compact_seps(T, [nil|Acc]);
compact_seps([sep, Value|T], Acc) ->
    compact_seps(T, [Value|Acc]);
compact_seps([H|T], Acc) ->
    compact_seps(T, [H|Acc]).

