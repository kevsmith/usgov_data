defmodule USGovData.CandidateMasterTest do
  use ExUnit.Case
  alias USGovData.Test.Support.Assets
  alias USGovData.Parsers.CandidateMaster

  test "can parse whole file" do
    case USGovData.Parser.parse_file(Assets.path_to("candidate_master.csv"), CandidateMaster) do
      {:ok, result} ->
        assert(60 == length(result))

      error ->
        raise RuntimeError, message: "Unexpected result: #{inspect(error)}"
    end
  end
end
