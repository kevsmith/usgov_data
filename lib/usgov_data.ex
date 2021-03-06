defmodule USGovData.Parser do
  @doc """
  Parses a file using specific parser module
  """
  @spec parse_file(String.t(), atom, Keyword.t()) ::
          {:ok, [term]} | {:error, non_neg_integer, atom}
  def parse_file(path, parser, opts \\ []) do
    file_opts = parse_file_opts(path, opts)
    drop_errors = parse_drop_errors(opts)

    case File.open(path, file_opts) do
      {:ok, fd} ->
        read_and_parse(fd, parser, 1, [], drop_errors)

      error ->
        error
    end
  end

  @doc """
  Parses a single line using specific parser module
  """
  @spec parse_line(String.t(), atom, Keyword.t()) ::
          {:ok, [term]} | {:error, non_neg_integer, atom}
  def parse_line(line, parser, opts \\ []) do
    drop_errors = parse_drop_errors(opts)

    line =
      if String.ends_with?(line, "\n") do
        line
      else
        line <> "\n"
      end

    case apply(parser, :parse_line, [line]) do
      {:ok, parsed} ->
        {:ok, parsed}

      {:error, reason} ->
        if drop_error?(drop_errors, reason) do
          {:ok, []}
        else
          {:error, 1, reason}
        end
    end
  end

  defp drop_error?([:all], _error), do: true
  defp drop_error?(drops, error), do: Enum.member?(drops, error)

  defp read_and_parse(fd, parser, linum, acc, drop_errors) do
    case :file.read_line(fd) do
      {:ok, line} ->
        line =
          if String.ends_with?(line, "\n") do
            line
          else
            line <> "\n"
          end

        case apply(parser, :parse_line, [line]) do
          {:ok, parsed} ->
            read_and_parse(fd, parser, linum + 1, [parsed | acc], drop_errors)

          {:error, reason} ->
            if drop_error?(drop_errors, reason) do
              read_and_parse(fd, parser, linum + 1, acc, drop_errors)
            else
              {:error, linum, reason}
            end
        end

      :eof ->
        {:ok, Enum.reverse(acc)}

      {:error, reason} ->
        {:error, linum, reason}
    end
  end

  defp parse_file_opts(path, opts) do
    fopts = [:read, :binary]

    if Keyword.get(opts, :compressed) == true or String.ends_with?(path, ".gz") do
      [:compressed | fopts]
    else
      fopts
    end
  end

  defp parse_drop_errors(opts) do
    drop_errors =
      case Keyword.get(opts, :drop_errors) do
        error when is_atom(error) ->
          [error]

        errs when is_list(errs) ->
          errs

        _ ->
          []
      end

    consolidate_drops(drop_errors)
  end

  defp consolidate_drops(errors) do
    if Enum.member?(errors, :all) do
      [:all]
    else
      errors |> Enum.uniq()
    end
  end
end
