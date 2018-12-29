defmodule USGovData.Parsers.CommitteeMaster do
  defstruct([
    :address1,
    :address2,
    :candidate,
    :city,
    :connected_org,
    :designation,
    :filing_frequency,
    :id,
    :name,
    :org_category,
    :party,
    :state,
    :treasurer,
    :type,
    :zip_code
  ])

  @type committee_designation ::
          :candidate_authorized
          | :lobbyist_pac
          | :leadership_pac
          | :joint_fundraiser
          | :principal_committee
          | :unauthorized
          | {:unknown_code, String.t()}

  @type filing_frequency ::
          :admin_terminated
          | :debt
          | :monthly
          | :quarterly
          | :terminated
          | :waived
          | {:unknown_frequency, String.t()}

  @type org_category ::
          :corp
          | :labor
          | :membership
          | :trade_assoc
          | :coop
          | :corp_no_cap_stock
          | {:unknown_category, String.t()}

  @type t :: %__MODULE__{
          address1: String.t(),
          address2: String.t(),
          candidate: String.t(),
          city: String.t(),
          connected_org: String.t(),
          designation: committee_designation() | nil,
          filing_frequency: filing_frequency() | nil,
          id: String.t(),
          name: String.t(),
          org_category: org_category() | nil,
          party: String.t(),
          state: String.t(),
          treasurer: String.t(),
          type: String.t(),
          zip_code: String.t()
        }

  @doc """
  Parses a line from a committee master FEC data file
  """
  @spec parse_line(line :: String.t()) :: {:ok, __MODULE__.t()} | {:error, atom}
  def parse_line(line) do
    case :csv_parser.scan_and_parse(line) do
      {:ok, fields} ->
        case length(fields) do
          15 ->
            %__MODULE__{
              address1: Enum.at(fields, name2off(:address1)),
              address2: Enum.at(fields, name2off(:address2)),
              candidate: Enum.at(fields, name2off(:candidate)),
              city: Enum.at(fields, name2off(:city)),
              connected_org: Enum.at(fields, name2off(:connected_org)),
              designation: Enum.at(fields, name2off(:designation)),
              filing_frequency: Enum.at(fields, name2off(:filing_frequency)),
              id: Enum.at(fields, name2off(:id)),
              name: Enum.at(fields, name2off(:name)),
              org_category: Enum.at(fields, name2off(:org_category)),
              party: Enum.at(fields, name2off(:party)),
              state: Enum.at(fields, name2off(:state)),
              treasurer: Enum.at(fields, name2off(:treasurer)),
              type: Enum.at(fields, name2off(:type)),
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
  defp name2off(:treasurer), do: 2
  defp name2off(:address1), do: 3
  defp name2off(:address2), do: 4
  defp name2off(:city), do: 5
  defp name2off(:state), do: 6
  defp name2off(:zip_code), do: 7
  defp name2off(:designation), do: 8
  defp name2off(:type), do: 9
  defp name2off(:party), do: 10
  defp name2off(:filing_frequency), do: 11
  defp name2off(:org_category), do: 12
  defp name2off(:connected_org), do: 13
  defp name2off(:candidate), do: 14

  defp translate_designation("A"), do: :candidate_authorized
  defp translate_designation("B"), do: :lobbyist_pac
  defp translate_designation("D"), do: :leadership_pac
  defp translate_designation("J"), do: :joint_fundraiser
  defp translate_designation("P"), do: :principal_committee
  defp translate_designation("U"), do: :unauthorized
  defp translate_designation(nil), do: nil
  defp translate_designation(d) when is_binary(d), do: {:unknown_code, d}

  defp translate_frequency("A"), do: :admin_terminated
  defp translate_frequency("D"), do: :debt
  defp translate_frequency("M"), do: :monthly
  defp translate_frequency("Q"), do: :quarterly
  defp translate_frequency("T"), do: :terminated
  defp translate_frequency("W"), do: :waived
  defp translate_frequency(nil), do: nil
  defp translate_frequency(f) when is_binary(f), do: {:unknown_frequency, f}

  defp translate_category("C"), do: :corp
  defp translate_category("L"), do: :labor
  defp translate_category("M"), do: :membership
  defp translate_category("T"), do: :trade_assoc
  defp translate_category("V"), do: :coop
  defp translate_category("W"), do: :corp_no_cap_stock
  defp translate_category(nil), do: nil
  defp translate_category(c) when is_binary(c), do: {:unknown_category, c}

  defp validate(%__MODULE__{address2: add2} = r) when is_integer(add2) do
    validate(%{r | address2: "#{add2}"})
  end

  defp validate(%__MODULE__{zip_code: zc} = r) when is_integer(zc) do
    validate(%{r | zip_code: "#{zc}"})
  end

  defp validate(
         %__MODULE__{designation: d, filing_frequency: f, org_category: c, address2: add2} = r
       ) do
    updated_d = translate_designation(d)
    updated_f = translate_frequency(f)
    updated_c = translate_category(c)

    updated_add2 =
      if add2 != nil and String.length(add2) < 2 do
        nil
      else
        add2
      end

    {:ok,
     %{
       r
       | designation: updated_d,
         filing_frequency: updated_f,
         org_category: updated_c,
         address2: updated_add2
     }}
  end
end
