defmodule Mix.Tasks.Geocode do

  alias MkePolice.{Repo, Call, Scanner}

  import Ecto.Query

  def run(_) do
    Application.ensure_all_started(:ecto)
    Application.ensure_all_started(:postgrex)

    HTTPoison.start
    Repo.start_link

    from(call in Call, 
      where: is_nil(call.point),
      limit: 1000,
      order_by: [desc: call.time]
    )
    |> Repo.all()
    |> Enum.each(fn(call) ->
      {lat, lng} = Geocode.lookup(call.location) 
      Repo.update!(Call.changeset(call, %{point: %Geo.Point{coordinates: {lng, lat}, srid: 4326}}))
    end)
  end
end
