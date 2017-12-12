defmodule MkePolice.Scanner do

  alias MkePolice.{Repo, Call}
  require Logger
  import Ecto.Query

  @name __MODULE__

  defmodule State do
    defstruct interval: nil, server_pid: nil
  end

  def start_link(sup_pid, restart_interval) do
    GenServer.start_link(__MODULE__, [sup_pid, restart_interval], name: @name)
  end

  def init([callback, interval]) do
    GenServer.cast(callback, {:scanner_started, self})
    Process.send_after(self(), :scan, interval)
    {:ok, %State{interval: interval, server_pid: callback}}
  end

  def handle_info(:scan, state = %{interval: interval}) do
    calls()
    |> Enum.each(fn(call) ->
        call_id = call[:call_id]
        rcall = from(c in Call, where: c.call_id == ^call_id, order_by: [desc: c.inserted_at], limit: 1) |> Repo.one
        {_, call} = Map.get_and_update!(call, :time, fn(current_time) ->
          {current_time, Timex.parse!(current_time, "{0M}/{0D}/{YYYY} {h12}:{m}:{s} {AM}")}
        end)

        case rcall do
          nil   ->
            call = case Geocode.lookup(call.location) do
              {nil, nil} -> call
              {lat, lng} -> Map.put(call, :point, %Geo.Point{coordinates: {lng, lat}, srid: 4326})
            end
            rcall = Repo.insert!(Call.changeset(%Call{}, call))
            MkePolice.Endpoint.broadcast("calls:all", "new", rcall)
            MkePolice.Endpoint.broadcast("calls:#{rcall.district}", "new", rcall)
          rcall ->
            if(rcall.status != call[:status] || rcall.nature != call[:nature]) do
              call = Map.put(call, :point, rcall.point)
              rcall = Repo.insert!(Call.changeset(%Call{}, call))
              MkePolice.Endpoint.broadcast("calls:all", "new", rcall)
              MkePolice.Endpoint.broadcast("calls:#{rcall.district}", "new", rcall)
            end
        end

     end)

    Process.send_after(self(), :scan, interval)
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.error "Scanner died: #{inspect reason} (#state)"
  end

  def calls() do
    MkePolice.Scraper.fetch
  end

end
