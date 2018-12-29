defmodule USGovData.Parsers.CandidateMaster do
  defstruct([
    :address1,
    :address2,
    :city,
    :election_year,
    :ici,
    :id,
    :name,
    :office_district,
    :office_state,
    :party,
    :pcc,
    :state,
    :status,
    :type,
    :zip_code
  ])

  @type candidate_type :: :house | :senate | :president

  @type t :: %__MODULE__{
          address1: String.t(),
          address2: String.t(),
          city: String.t(),
          election_year: non_neg_integer,
          ici: String.t(),
          id: String.t(),
          name: String.t(),
          office_district: String.t(),
          office_state: String.t(),
          party: String.t(),
          pcc: String.t(),
          state: String.t(),
          status: String.t(),
          type: candidate_type(),
          zip_code: String.t()
        }

  @doc """
  Parses a line from a candidate master FEC data file
  """
  @spec parse_line(line :: String.t()) :: {:ok, __MODULE__.t()} | {:error, atom}
  def parse_line(line) do
    case :csv_parser.scan_and_parse(line) do
      {:ok, fields} ->
        fields = maybe_pad(fields)

        case length(fields) do
          15 ->
            %__MODULE__{
              type: Enum.at(fields, name2off(:type)),
              id: Enum.at(fields, name2off(:id)),
              name: Enum.at(fields, name2off(:name)),
              party: Enum.at(fields, name2off(:party)),
              election_year: Enum.at(fields, name2off(:election_year)),
              office_state: Enum.at(fields, name2off(:office_state)),
              office_district: Enum.at(fields, name2off(:office_district)),
              ici: Enum.at(fields, name2off(:ici)),
              status: Enum.at(fields, name2off(:status)),
              pcc: Enum.at(fields, name2off(:pcc)),
              address1: Enum.at(fields, name2off(:address1)),
              address2: Enum.at(fields, name2off(:address2)),
              city: Enum.at(fields, name2off(:city)),
              state: Enum.at(fields, name2off(:state)),
              zip_code: Enum.at(fields, name2off(:zip_code))
            }
            |> validate

          _ ->
            {:error, :bad_field_count}
        end

      error ->
        error
    end
  end

  defp name2off(:id), do: 0
  defp name2off(:name), do: 1
  defp name2off(:party), do: 2
  defp name2off(:election_year), do: 3
  defp name2off(:office_state), do: 4
  defp name2off(:type), do: 5
  defp name2off(:office_district), do: 6
  defp name2off(:ici), do: 7
  defp name2off(:status), do: 8
  defp name2off(:pcc), do: 9
  defp name2off(:address1), do: 10
  defp name2off(:address2), do: 11
  defp name2off(:city), do: 12
  defp name2off(:state), do: 13
  defp name2off(:zip_code), do: 14

  defp validate(%__MODULE__{election_year: ey}) when is_integer(ey) == false do
    {:error, :bad_election_year}
  end

  defp validate(%__MODULE__{type: type}) when type not in ["H", "S", "P"] do
    {:error, :bad_candidate_type}
  end

  defp validate(%__MODULE__{type: type, zip_code: zip_code} = r) do
    updated =
      case type do
        "H" ->
          :house

        "S" ->
          :senate

        "P" ->
          :president
      end

    {:ok, %{r | type: updated, zip_code: "#{zip_code}"}}
  end

  defp maybe_pad(fields) do
    if length(fields) < 15 do
      maybe_pad(fields ++ [nil])
    else
      fields
    end
  end
end
