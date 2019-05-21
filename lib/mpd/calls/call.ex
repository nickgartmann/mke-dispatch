defmodule Mpd.Calls.Call do
  use Ecto.Schema
  import Ecto.Changeset

  schema "calls" do
    field :call_id, :string
    field :district, :string
    field :location, :string
    field :nature, :string
    field :status, :string
    field :time, :naive_datetime

    field :point, Geo.PostGIS.Geometry

    timestamps()
  end

  @doc false
  def changeset(call, attrs) do
    call
    |> cast(attrs, [:time, :location, :district, :nature, :status, :call_id, :point])
    |> validate_required([:time, :location, :district, :nature, :status, :call_id])
  end
end
