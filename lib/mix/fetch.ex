defmodule Mix.Tasks.FetchPoliceData do
  use Mix.Task

  alias MkePolice.{Repo, Call, Scanner}
  
  def run(_) do
    Application.ensure_all_started(:ecto)
    Application.ensure_all_started(:postgrex)

    HTTPoison.start
    Repo.start_link

    Scanner.calls()
    |> Enum.each(fn(call) ->
      rcall = Repo.get(Call, call.id)
      {_, call} = Map.get_and_update!(call, :time, fn(current_time) ->
        {current_time, Timex.parse!(current_time, "{0M}/{0D}/{YYYY} {h12}:{m}:{s} {AM}")}
      end)
      case rcall do
        nil   -> Repo.insert!(Call.changeset(%Call{}, call))
        rcall -> Repo.update!(Call.changeset(rcall, call))
      end
    end)
  end
  
end

