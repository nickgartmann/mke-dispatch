defmodule MkePolice.ScannerSupervisor do
  require Logger
  use Supervisor

  @name : __MODULE__

  ## API

  def start_link(restart_interval) do
    Supervisor.start_link(__MODULE__, restart_interval, name: @name)
  end

  ## Callbacks

  def init(restart_interval) do
    opts = [
      strategy: :one_for_all
    ]
    children = [
      worker(MkePolice.ScannerServer, [{self, restart_interval}],
        [name: :"MkePolice.ScannerServer"]),
    ]
    supervise(children, opts)
  end

  ## Helpers

end
