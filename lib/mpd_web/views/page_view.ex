defmodule MpdWeb.PageView do
  use MpdWeb, :view

  def render_date(date, format \\ :long)

  def render_date(date, :long) do
    "#{render_month(date.month)} #{date.day}, #{date.year}"
  end

  def render_date(date, :short), do: "#{date.month}/#{date.day}"

  def render_month(1), do: "January"
  def render_month(2), do: "February"
  def render_month(3), do: "March"
  def render_month(4), do: "April"
  def render_month(5), do: "May"
  def render_month(6), do: "June"
  def render_month(7), do: "July"
  def render_month(8), do: "August"
  def render_month(9), do: "September"
  def render_month(10), do: "October"
  def render_month(11), do: "November"
  def render_month(12), do: "December"

  def render_time(time) do
    "#{render_hour(time)}:#{render_minute(time)} #{render_ampm(time)}"
  end

  defp render_hour(time) do
    if time.hour == 0 or time.hour == 12 do
      "12"
    else
      "#{rem(time.hour, 12)}"
    end
  end

  defp render_minute(time) do
    if time.minute < 10 do
      "0#{time.minute}"
    else
      "#{time.minute}"
    end
  end

  defp render_ampm(time) do
    if time.hour < 12 do
      "am"
    else
      "pm"
    end
  end
end
