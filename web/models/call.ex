defmodule MkePolice.Call do
  use MkePolice.Web, :model

  schema "calls" do
    field :time, Ecto.DateTime
    field :location, :string
    field :district, :integer
    field :nature, :string
    field :status, :string

    field :point, Geo.Point

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :time, :location, :district, :nature, :status, :point])
    |> validate_required([:id, :time, :location, :district, :nature, :status])
  end
end

defimpl Poison.Encoder, for: MkePolice.Call do
  def encode(call, options \\ []) do
    {longitude, latitude} = case call.point do 
      nil -> {nil, nil}
      pt  -> {lng, lat} = pt.coordinates 
    end

    %{
      id: call.id,
      time: call.time,
      location: call.location,
      district: call.district,
      nature: call.nature,
      status: call.status,
      latitude: latitude,
      longitude: longitude
    }
    |> Poison.Encoder.encode(options)
  end
end

