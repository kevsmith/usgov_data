defmodule USGovData.Test.Support.Assets do
  def path_to(asset) do
    Path.join(assets_path(), asset)
  end

  defp assets_path() do
    Path.join([File.cwd!(), "test", "assets"])
  end
end
