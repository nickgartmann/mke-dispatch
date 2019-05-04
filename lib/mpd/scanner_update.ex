defmodule Mpd.ScannerUpdate do
  @topic "calls:new"

  def subscribe_live_view_new_calls do
    Phoenix.PubSub.subscribe(Mpd.PubSub, topic())
  end

  def notify_live_view_new_calls do
    Phoenix.PubSub.broadcast(Mpd.PubSub, topic(), {Mpd.ScannerUpdate, :new_calls})
  end

  defp topic() do
    @topic
  end
end
