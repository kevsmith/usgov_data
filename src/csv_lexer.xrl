Definitions.

FIELDSEP               = \|\s*
INTEGER                = [1-9]([0-9])*
QUOTED_TEXT            = "(\\\^.|\\.|[^"\n])*"
TEXT                   = ([^\|\n]||\\.)*
US_DATE_SLASH          = [0-9][0-9]?/[0-9][0-9]?/[0-9][0-9][0-9][0-9]
US_DATE_DASH           = [0-9][0-9]?\-[0-9][0-9]?\-[0-9][0-9][0-9][0-9]

Rules.

{FIELDSEP}             : {token, {fieldsep, "|"}}.
{US_DATE_SLASH}        : {token, {date, parse_date(TokenChars, "/")}}.
{US_DATE_DASH}         : {token, {date, parse_date(TokenChars, "-")}}.
{INTEGER}              : {token, {integer, erlang:list_to_integer(TokenChars)}}.
{QUOTED_TEXT}          : {token, {text, string:trim(TokenChars, both, "\"")}}.
{TEXT}                 : {token, {text, TokenChars}}.
\n                     : skip_token.


Erlang code.
parse_date(TokenChars, Sep) ->
    [Month, Day, Year] = string:tokens(TokenChars, Sep),
    {list_to_integer(Year), list_to_integer(Month), list_to_integer(Day)}.
