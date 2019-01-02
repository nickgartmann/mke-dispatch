defmodule Geocode do 

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
    query = from(call in MkePolice.Call,
      where: call.location == ^address and not is_nil(call.point),
      limit: 1
    )
    case MkePolice.Repo.one(query) do
      nil -> {:error, nil}
      call -> {:ok, call.point.coordinates} 
    end
  end

  defp lookup_from_google(address) do
    IO.puts "Querying google for #{address}"
    %{ "lat" => lat, "lng" => lng} = HTTPoison.get!(url(address))
    |> Map.get(:body)
    |> Poison.decode!()
    |> Dict.get("results")
    |> case do
      [] -> [%{"geometry" => %{"location" => %{"lat" => nil, "lng" => nil}}}]
      res -> res
    end
    |> Enum.at(0)
    |> Dict.get("geometry")
    |> Dict.get("location")
    {:ok, {lat, lng}}
  end

  defp url(address) do
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)}&key=#{Application.get_env(:mke_police, Geocode)[:google_api_key]}"
  end
end
