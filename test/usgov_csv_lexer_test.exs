defmodule USGovData.CSVLexerTest do
  use ExUnit.Case

  test "simple csv line" do
    {:ok, lexed, 1} = :csv_lexer.string('a|b|c|d')
    assert(length(lexed) == 7)
    [first | _] = lexed
    assert({:text, 'a'} == first)
  end

  test "quoted text" do
    {:ok, lexed, 1} = :csv_lexer.string('"a"|b|c|"d"')
    assert(length(lexed) == 7)
    [first | _] = lexed
    assert({:text, 'a'} == first)
  end

  test "numbers" do
    {:ok, lexed, 1} = :csv_lexer.string('123|456|c|d')
    assert(length(lexed) == 7)
    [first, _, second, _, third | _] = lexed
    assert({:integer, 123} == first)
    assert({:integer, 456} == second)
    assert({:text, 'c'} == third)
  end

  test "empty fields" do
    {:ok, lexed, 1} = :csv_lexer.string('123||c|d')
    assert(length(lexed) == 6)
    [first, sep1, sep2, second | _] = lexed
    assert({:integer, 123} == first)
    assert({:fieldsep, '|'} == sep1)
    assert({:fieldsep, '|'} == sep2)
    assert({:text, 'c'} == second)
  end

  test "empty fields at end" do
    {:ok, lexed, 1} = :csv_lexer.string('a|b|c||')
    assert(length(lexed) == 7)
    [last, next | _] = Enum.reverse(lexed)
    assert({:fieldsep, '|'} == last)
    assert({:fieldsep, '|'} == next)
    [first, _, second, _, third | _] = lexed
    assert({:text, 'a'} == first)
    assert({:text, 'b'} == second)
    assert({:text, 'c'} == third)
  end

  test "escaped pipe delimiter" do
    {:ok, lexed, 1} = :csv_lexer.string('abc|def\\|g|hij')
    assert(length(lexed) == 5)
    [first, _, second, third, fourth] = lexed
    assert({:text, 'abc'} == first)
    assert({:text, 'def\\|g'} == second)
    assert({:fieldsep, '|'} == third)
    assert({:text, 'hij'} == fourth)
  end
end
