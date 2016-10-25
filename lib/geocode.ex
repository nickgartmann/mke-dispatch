defmodule Geocode do 
  def lookup(address) do 
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
    {lat, lng}
  end

  defp url(address) do
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)}&key=#{Application.get_env(:mke_police, Geocode)[:google_api_key]}"
  end
end
