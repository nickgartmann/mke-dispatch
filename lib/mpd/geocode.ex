defmodule Mpd.Geocode do
  import Ecto.Query

  def lookup(address) do case lookup_from_database(address) do
      {:ok, coordinates} ->
        coordinates
      {:error, _} ->
        {:ok, coordinates} = lookup_from_google(address)
        coordinates
    end
  end

  defp lookup_from_database(address) do
    query = from(call in Mpd.Calls.Call,
      where: call.location == ^address and not is_nil(call.point),
      limit: 1
    )
    case Mpd.Repo.one(query) do
      nil -> {:error, nil}
      call -> {:ok, call.point.coordinates}
    end
  end

  defp lookup_from_google(address) do
    IO.puts "Querying google for #{address}"
    with {:ok, 200, _headers, client} <- :hackney.get(url(address)),
         {:ok, body} <- :hackney.body(client),
         {:ok, json} <- Jason.decode(body) do

      %{ "lat" => lat, "lng" => lng} =
        Map.get(json, "results")
        |> case do
          [] -> [%{"geometry" => %{"location" => %{"lat" => nil, "lng" => nil}}}]
          res -> res
        end
        |> Enum.at(0)
        |> Map.get("geometry")
        |> Map.get("location")

        {:ok, {lat, lng}}
    end
  end

  defp url(address) do
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)}&key=#{Application.get_env(:mke_police, Geocode)[:google_api_key]}"
  end
end
