defmodule Mpd.Scanner do
  use GenServer

  alias Mpd.Repo
  alias Mpd.Calls.Call
  require Logger
  import Ecto.Query
  import NimbleParsec

  @name __MODULE__

  defmodule State do
    defstruct scan_interval: nil
  end

  def start_link(scan_interval) do
    GenServer.start_link(__MODULE__, [scan_interval], name: @name)
  end

  def init([scan_interval]) do
    Process.send_after(self(), :scan, 2_000)
    {:ok, %State{scan_interval: scan_interval}}
  end

  def handle_info(:scan, state = %{scan_interval: scan_interval}) do
    {:ok, calls} = calls()
    Enum.each(calls, fn(call) ->
        call_id = call[:call_id]
        rcall = from(c in Call, where: c.call_id == ^call_id, order_by: [desc: c.inserted_at], limit: 1) |> Repo.one
        {_, call} = Map.get_and_update!(call, :time, fn(current_time) ->
          {current_time, parse_date(current_time)}#, "{0M}/{0D}/{YYYY} {h12}:{m}:{s} {AM}")}
        end)

        case rcall do
          nil   ->
            call = case Mpd.Geocode.lookup(call.location) do
              {nil, nil} -> call
              {lat, lng} -> Map.put(call, :point, %Geo.Point{coordinates: {lng, lat}, srid: 4326})
            end
            rcall = Repo.insert!(Call.changeset(%Call{}, call))
          rcall ->
            if(rcall.status != call[:status] || rcall.nature != call[:nature]) do
              call = Map.put(call, :point, rcall.point)
              rcall = Repo.insert!(Call.changeset(%Call{}, call))
            end
        end

     end)

    Mpd.ScannerUpdate.notify_live_view_new_calls()
    Process.send_after(self(), :scan, scan_interval)
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.error "Scanner died: #{inspect reason} (#{inspect state})"
  end

  def calls() do
    Mpd.Scraper.fetch
  end

  datetime =
    integer(2)
    |> ignore(string("/"))
    |> integer(2)
    |> ignore(string("/"))
    |> integer(4)
    |> ignore(string(" ")) 
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(" "))
    |> choice([string("AM"), string("PM")])

  defparsec :datetime, datetime

  defp parse_date(string) do
    case datetime(string) do
      {:ok, [month, day, year, 12, minute, second, "PM"], _, _, _, _} ->
        %NaiveDateTime{month: month, day: day, year: year, hour: 12, minute: minute,
          second: second}
      {:ok, [month, day, year, hour, minute, second, "PM"], _, _, _, _} ->
        %NaiveDateTime{month: month, day: day, year: year, hour: hour + 12, minute: minute,
          second: second}
      {:ok, [month, day, year, hour, minute, second, "AM"], _, _, _, _} ->
        %NaiveDateTime{month: month, day: day, year: year, hour: hour, minute: minute,
          second: second}
    end
  end
end
