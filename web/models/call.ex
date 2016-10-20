defmodule MkePolice.Call do
  use MkePolice.Web, :model

  schema "calls" do
    field :time, Ecto.DateTime
    field :location, :string
    field :district, :integer
    field :nature, :string
    field :status, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :time, :location, :district, :nature, :status])
    |> validate_required([:id, :time, :location, :district, :nature, :status])
  end
end

defimpl Poison.Encoder, for: MkePolice.Call do
  def encode(call, options \\ []) do
    %{
      id: call.id,
      time: call.time,
      location: call.location,
      district: call.district,
      nature: call.nature,
      status: call.status
    }
    |> Poison.Encoder.encode(options)
  end
end

