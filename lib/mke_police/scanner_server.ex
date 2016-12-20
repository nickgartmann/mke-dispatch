defmodule MkePolice.ScannerServer do
  require Logger
  use GenServer
  import Supervisor.Spec

  @name __MODULE__

  defmodule State do
    defstruct interval: nil, parent: nil, scanner: nil, scanner_state: nil
  end

  ## API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  ## Callbacks

  def init({sup_pid, restart_interval}) do
    send(self, :start_scanner)
    {:ok, %State{interval: restart_interval, parent: sup_pid}}
  end

  def handle_cast({:scanner_started, scanner_pid}, state) when is_pid(scanner_pid) do
    Process.flag(:trap_exit, true)
    Process.link(scanner_pid)
    {:noreply, %{state | scanner: scanner_pid}}
  end

  def handle_info(:start_scanner, state = %{interval: interval, parent: sup_pid}) do
    # NOTE: Not sure whether to put scanner into state here,
    # or only count it as existing once it sends a message back
    _scanner_pid = start_scanner(sup_pid, interval)
    {:noreply, state}
  end

  def handle_info({:EXIT, pid, reason},
    state = %{scanner: pid, interval: interval, parent: sup_pid}) do

    Logger.error "Scanner died: #{inspect reason} (#{DateTime.utc_now |> DateTime.to_string})"

    # NOTE: See note in handle_cast/2
    _scanner_pid = start_scanner(sup_pid, interval)
    {:noreply, %{state | scanner: nil}}
  end

  ## Helpers

  defp start_scanner(sup_pid, interval) do
    opts = [name: "MkePolice.Scanner", restart: :temporary]
    scanner = worker(MkePolice.Scanner, [self, interval], opts)
    {:ok, scanner_pid} = Supervisor.start_child(sup_pid, scanner)
    scanner_pid
  end

end
