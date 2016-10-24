defmodule Geocode do 
  def lookup(address) do 
    %{ "lat" => lat, "lng" => lng} = HTTPoison.get!(url(address))
    |> Map.get(:body)
    |> Poison.decode!()
    |> Map.get("results")
    |> Enum.at(0)
    |> Map.get("geometry")
    |> Map.get("location")
    {lat, lng}
  end

  defp url(address) do
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)}&key=#{Application.get_env(:mke_police, Geocode)[:google_api_key]}"
  end
end
