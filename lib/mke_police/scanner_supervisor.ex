defmodule MkePolice.ScannerSupervisor do
  require Logger
  use Supervisor

  ## API

  def start_link(restart_interval) do
    GenServer.start_link(__MODULE__, restart_interval)
  end

  ## Callbacks

  def init(restart_interval) do
    sup_scanner(restart_interval)
    # {:ok, %{restart_interval: restart_interval}}
  end

  def handle_info({:scanner_started, scanner_pid}, state) do
    Process.flag(:trap_exit, true)
    {:ok, %{state | scanner: scanner_pid}}
  end

  def handle_info({:EXIT, pid, reason}, state = %{scanner: pid, restart_interval: interval}) do
    Logger.error "Scanner died: #{inspect reason}"
    sup_scanner(interval)
    {:ok, %{state | scanner: nil}}
  end

  ## Helpers

  defp sup_scanner(restart_interval) do
    opts = [
      strategy: :one_for_one
    ]
    children = [
      worker(MkePolice.Scanner, [self, restart_interval], restart: :temporary)
    ]
    supervise(children, opts)
  end

end
