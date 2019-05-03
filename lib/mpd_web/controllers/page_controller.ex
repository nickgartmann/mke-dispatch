defmodule MpdWeb.PageController do
  use MpdWeb, :controller

  def index(conn, %{"date" => date}) do
    {:ok, date} = Date.from_iso8601(date)
    calls = Mpd.Calls.list_date(date)
    render(conn, "index.html", calls: calls, date: date)
  end

  def index(conn, _), do: index(conn, %{"date" => Date.to_string(Date.utc_today())})

  def calls(conn, %{"id" => id}) do
    calls = Mpd.Calls.get_by_id(id)
    call = hd(calls)
    {lat, lng} = get_lat_lng(call)

    render(conn, "call.html", calls: calls, lat: lat, lng: lng, call: call)
  end

  def about(conn, _) do
    render(conn, "about.html")
  end

  def contribute(conn, _) do
    render(conn, "contribute.html")
  end

  def bulk(conn, _) do
    render(conn, "bulk.html")
  end

  defp get_lat_lng(nil), do: {nil, nil}
  defp get_lat_lng(%{point: nil}), do: {nil, nil}
  defp get_lat_lng(%{point: %{coordinates: {lat, lng}}}), do: {lat, lng}
end
