defmodule MpdWeb.CallIndexLive do
  use Phoenix.LiveView
  require Logger

  def mount(%{date: date}, socket) do
    calls = Mpd.Calls.list_date(date)

    Mpd.ScannerUpdate.subscribe_live_view_new_calls()

    socket = assign(socket, :date, date)
             |> assign(:calls, calls)

    {:ok, socket}
  end

  def handle_info({Mpd.ScannerUpdate, :new_calls}, socket) do
    Logger.info("LIVE VIEW RECEIVED SCANNER UPDATE")
    calls = Mpd.Calls.list_date(socket.assigns.date)

    {:noreply, assign(socket, calls: calls)}
  end

  def render(assigns) do
    MpdWeb.PageView.render("index.html", assigns)
  end
end
