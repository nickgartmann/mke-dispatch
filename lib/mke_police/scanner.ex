defmodule MkePolice.Scanner do 

  alias MkePolice.{Repo, Call}
  

  def start_link(restart_interval) do 
    GenServer.start_link(__MODULE__, restart_interval)
  end

  def init(interval) do
    Process.send_after(self(), :scan, interval)
    {:ok, interval}
  end

  def handle_info(:scan, interval) do
    calls()
    |> Enum.each(fn(call) ->

        rcall = Repo.get(Call, call.id)
        {_, call} = Map.get_and_update!(call, :time, fn(current_time) ->
          {current_time, Timex.parse!(current_time, "{0M}/{0D}/{YYYY} {h12}:{m}:{s} {AM}")}
        end)

        case rcall do
          nil   -> 
            rcall = Repo.insert!(Call.changeset(%Call{}, call))
            MkePolice.Endpoint.broadcast("calls", "new", rcall)
            MkePolice.Endpoint.broadcast("calls:#{rcall.district}", "new", rcall)
          rcall -> 
            rcall = Repo.update!(Call.changeset(rcall, call))
            MkePolice.Endpoint.broadcast("calls", "update", rcall)
            MkePolice.Endpoint.broadcast("calls:#{rcall.district}", "update", rcall)
        end

     end)

    Process.send_after(self(), :scan, interval)
    {:noreply, interval}
  end


  def calls() do
    get_calls()
  end

  defp get_calls(pages \\ nil)
  defp get_calls(nil), do: get_calls(get_page())
  defp get_calls(%{calls: calls, page: {x, x}, view_state: view_state, cookies: cookies}), do: calls
  defp get_calls(%{calls: calls, page: {current_page, end_page}, view_state: view_state, cookies: cookies}) do 
    calls ++ get_calls(get_page(view_state, cookies))
  end
  

  defp get_page() do
    response = HTTPoison.get!("http://itmdapps.milwaukee.gov/MPDCallData/currentCADCalls/callsService.faces") 

    view_state = response.body
    |> Floki.find("[name='javax.faces.ViewState']")
    |> Enum.at(0)
    |> elem(1)
    |> Keyword.new(fn({key,value}) -> {String.to_atom(key), value} end)
    |> Keyword.fetch!(:value)


    calls = response
    |> Map.get(:body) 
    |> Floki.find("[id*='formId:tableExUpdateId'] tbody tr")
    |> Enum.map(&parse_row/1)

    cookies = response.headers
    |> Enum.filter(fn({key, value}) -> key == "Set-Cookie" end)
    |> Enum.at(0)
    |> elem(1)

    %{
      view_state: view_state,
      cookies: [cookies],
      calls: tl(Enum.reverse(calls)),
      page: hd(Enum.reverse(calls)) |> Map.get(:location) |> parse_page()
    }
  end

  defp get_page(view_state, cookies) do
    response = HTTPoison.post!("http://itmdapps.milwaukee.gov/MPDCallData/currentCADCalls/callsService.faces", {:form, [
      {"formId", "formId"},
      {"formId:selectPoliceDistId", "all"},
      {"formId:tableExUpdateId:deluxe1__pagerNext.x", 11},
      {"formId:tableExUpdateId:deluxe1__pagerNext.y", 11},
      {"javax.faces.ViewState", view_state}
    ]}, %{}, hackney: [cookie: cookies]) 

    view_state = response.body
    |> Floki.find("[name='javax.faces.ViewState']")
    |> Enum.at(0)
    |> elem(1)
    |> Keyword.new(fn({key,value}) -> {String.to_atom(key), value} end)
    |> Keyword.fetch!(:value)

    calls = response
    |> Map.get(:body) 
    |> Floki.find("[id*='formId:tableExUpdateId'] tbody tr")
    |> Enum.map(&parse_row/1)

    %{
      view_state: view_state,
      cookies: cookies,
      calls: tl(Enum.reverse(calls)),
      page: hd(Enum.reverse(calls)) |> Map.get(:location) |> parse_page()
    }
  end


  defp parse_row({_tr, _attrs, children}) do
    %{
      id: Enum.at(children, 0) |> parse_cell(),
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
    |> elem(2)
    |> Enum.at(0)
  end

  defp parse_cell(rest) do
    rest
  end

  
  defp parse_district_cell({_el, _, children}) do

    district = case Enum.at(children, 0) do
      nil -> nil
      {"input", _, _} -> nil
      cell -> parse_cell(cell)
    end

    case district do
      "NTF"  -> -1
      "CITY" -> -1
      "OUT"  -> -1
      "ICS4" -> -1
      nil    -> nil
      id     -> String.to_integer(id)
    end
  end

  defp parse_time_cell({_el, _ , children}) do
    case Enum.at(children, 0) do
      nil -> nil
      {"input", _, _} -> nil
      cell -> parse_cell(cell)
    end
  end

  defp parse_page("Page " <> pages) do 
    [current, total] = String.split(pages, " of ") |> Enum.map(&String.to_integer/1)
    {current, total}
  end

end
