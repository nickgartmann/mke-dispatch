defmodule MkePolice.PageController do
  use MkePolice.Web, :controller

  alias MkePolice.Call

  def index(conn, %{"start" => start_date, "end" => end_date}) do

    start_date = Timex.parse!(start_date, "{ISO:Extended}")
    end_date = Timex.parse!(end_date, "{ISO:Extended}")

    calls = from(call in Call, 
      where: call.time >= ^start_date and call.time <= ^end_date,
      order_by: [desc: call.time]
    ) |> Repo.all

    render conn, "index.html", calls: calls, start_date: start_date, end_date: end_date
  end

  def index(conn, %{"start" => start_date}) do
    index(conn, %{
      "start" => start_date,
      "end"   => default_end_date()
    })
  end

  def index(conn, _) do
    index(conn, %{
      "start" => Timex.now("America/Chicago") |> Timex.beginning_of_day() |> Timex.format!("{ISO:Extended}"),
      "end"   => default_end_date()
    })
  end

  def csv(conn, %{"action" => "download", "format" => "csv", "start" => start_date, "end" => end_date}) do
    start_date = Timex.parse!(start_date, "{ISO:Extended}")
    end_date = Timex.parse!(end_date, "{ISO:Extended}")

    calls = from(call in Call, 
      where: call.time >= ^start_date and call.time <= ^end_date,
      order_by: [desc: call.time]
    ) |> Repo.all

    csv_content = calls 
      |> Enum.map(&Map.from_struct/1) 
      |> CSV.encode(headers: [:id, :time, :location, :district, :nature, :status] ) 
      |> Enum.to_list()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("Content-Disposition", "attachment; filename=\"MPD Call Data.csv\"")
    |> send_resp(200, csv_content)
  end

  def csv(conn, _) do 
    render conn, "csv.html"
  end


  # JSON view of all calls between start and end (datetimes in ISO:Extended)
  def calls(conn, %{"start" => start_date, "end" => end_date}) do
    
    start_date = Timex.parse!(start_date, "{ISO:Extended}")
    end_date = Timex.parse!(end_date, "{ISO:Extended}")

    calls = from(call in Call, 
      where: call.time >= ^start_date and call.time <= ^end_date,
      order_by: [desc: call.time]
    ) |> Repo.all

    json conn, calls

  end

  def calls(conn, %{"start" => start_date}) do
    calls(conn, %{
      "start" => start_date,
      "end"   => default_end_date()
    })
  end

  def calls(conn, _) do
    calls(conn, %{
      "start" => Timex.now("America/Chicago") |> Timex.beginning_of_day() |> Timex.format!("{ISO:Extended}"),
      "end"   => default_end_date()
    })
  end

  def map(conn, _) do 
    render(conn, "map.html")
  end

  defp default_start_date(), do: Timex.now("America/Chicago") |> Timex.beginning_of_day() |> Timex.format!("{ISO:Extended}")
  defp default_end_date(), do: Timex.now("America/Chicago") |> Timex.format!("{ISO:Extended}")
end
