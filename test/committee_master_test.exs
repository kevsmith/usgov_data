defmodule USGovData.CommitteeMasterTest do
  use ExUnit.Case
  alias USGovData.Test.Support.Assets
  alias USGovData.Parsers.CommitteeMaster

  @bad_field_count_line """
  C00347195|PRAIRIE POLITICAL ACTION COMMITTEE|MICHAEL EDWARD DALY|POST OFFICE BOX 2002||SPRINGFIELD|IL|62705|U|Q||M||
  """

  @good_line """
  C00345587|WESTCHESTER FUND FOR GOOD GOVERNMENT|CHARLES D WOOD|PO BOX 1149||YONKERS|NY|10703|U|N||Q||NONE|
  """

  test "can parse whole file" do
    case USGovData.Parser.parse_file(Assets.path_to("committee_master.csv"), CommitteeMaster) do
      {:ok, result} ->
        assert(59 == length(result))

      {:error, linum, reason} ->
        flunk("Parsing error on line #{linum}: #{reason}")
    end
  end

  test "bad field count fails" do
    assert(
      USGovData.Parser.parse_line(@bad_field_count_line, CommitteeMaster) ==
        {:error, 1, :bad_field_count}
    )
  end

  test "dropping bad_field_count works" do
    assert(
      USGovData.Parser.parse_line(@bad_field_count_line, CommitteeMaster,
        drop_errors: :bad_field_count
      ) == {:ok, []}
    )
  end

  test "parsing good line works" do
    {:ok, result} = USGovData.Parser.parse_line(@good_line, CommitteeMaster)

    assert("C00345587" == result.id)
    assert(:unauthorized == result.designation)
    assert("CHARLES D WOOD" == result.treasurer)
    assert(nil == result.org_category)
  end
end
