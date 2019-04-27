defmodule Mpd.Calls do

  import Ecto.Query

  alias Mpd.Repo
  alias Mpd.Calls.Call

  def list(start_date, end_date) do
    from(
      call in Call,
      where: call.time > ^start_date and call.time < ^end_date,
      order_by: [desc: :time, desc: :inserted_at]
    )
    |> Repo.all()
  end

  def list_date(date) do
    {:ok, start_datetime} = NaiveDateTime.new(date, ~T[00:00:00.000])
    {:ok, end_datetime} = NaiveDateTime.new(date, ~T[23:59:59.999])
    list(
      start_datetime,
      end_datetime
    )
  end

  def list_today() do
    list_date(Date.utc_today())
  end

  def get_by_id(id) do
    from(
      call in Call,
      where: call.call_id == ^id
    )
    |> Repo.all()
  end

end
