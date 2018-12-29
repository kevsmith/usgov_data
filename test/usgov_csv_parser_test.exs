defmodule USGovData.CSVParseTest do
  use ExUnit.Case

  test "all text fields" do
    {:ok, parsed} = :csv_parser.scan_and_parse("abc|def|ghi")
    assert(length(parsed) == 3)
    [first, second, third] = parsed
    assert("abc" == first)
    assert("def" == second)
    assert("ghi" == third)
  end

  test "quoted text field" do
    {:ok, parsed} = :csv_parser.scan_and_parse("\"abc\"|def|\"ghi\"")
    assert(length(parsed) == 3)
    [first, second, third] = parsed
    assert("abc" == first)
    assert("def" == second)
    assert("ghi" == third)
  end

  test "integer field" do
    {:ok, parsed} = :csv_parser.scan_and_parse("abc|123|def|456")
    assert(length(parsed) == 4)
    [first, second, third, fourth] = parsed
    assert("abc" == first)
    assert(123 == second)
    assert("def" == third)
    assert(456 == fourth)
  end

  test "floats parsed as integers" do
    {:ok, parsed} = :csv_parser.scan_and_parse("123|abc|3.141")
    assert(length(parsed) == 3)
    [first, second, third] = parsed
    assert(123 == first)
    assert("abc" == second)
    assert("3.141" == third)
  end

  test "date field" do
    {:ok, parsed} = :csv_parser.scan_and_parse("06/01/1950|abc|def|\"06/01/1950\"")
    assert(length(parsed) == 4)
    [first, second, third, fourth] = parsed
    assert(~D"1950-06-01" == first)
    assert("abc" == second)
    assert("def" == third)
    assert("06/01/1950" == fourth)
  end

  test "backslashes are parsed" do
    {:ok, parsed} = :csv_parser.scan_and_parse("a|b|c|\\d|e")
    assert(length(parsed) == 5)
    assert("\\d" == Enum.at(parsed, 3))
  end
end
