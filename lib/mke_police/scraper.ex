defmodule MkePolice.Scraper do

  def fetch do
    HTTPoison.get!("https://itmdapps.milwaukee.gov/MPDCallData/index.jsp?district=All")
    |> Map.get(:body)
    |> Floki.find(".content table > tbody > tr")
    |> Enum.map(&parse_row/1)
  end

  defp parse_row({_tr, _attrs, children}) do
    %{
      call_id: Enum.at(children, 0) |> parse_cell(),
      time: Enum.at(children, 1) |> parse_time_cell(),
      location: Enum.at(children, 2) |> parse_cell(),
      district: Enum.at(children, 3) |> parse_district_cell(),
      nature: Enum.at(children, 4) |> parse_cell(),
      status: Enum.at(children, 5) |> parse_cell()
    }
  end

  defp parse_cell(nil), do: ""
  defp parse_cell({_el, _, children}) do
    Enum.at(children, 0)
  end

  defp parse_cell(rest) do
    rest
  end


  defp parse_district_cell({_el, _, children}) do
    case Enum.at(children, 0) do
      nil -> nil
      {"input", _, _} -> nil
      cell -> parse_cell(cell)
    end
  end

  defp parse_time_cell({_el, _ , children}) do
    case Enum.at(children, 0) do
      nil -> nil
      {"input", _, _} -> nil
      cell -> parse_cell(cell)
    end
  end
end
