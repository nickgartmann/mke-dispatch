defmodule Mpd.ScannerTest do
  use ExUnit.Case, async: true

  alias Mpd.Scanner

  describe "date parser" do

    test "handles midnight correctly" do
      ~N[1990-01-01 00:00:00] = Scanner.parse_date("01/01/1990 12:00:00 AM")
    end

    test "handles noon correctly" do
      ~N[1990-01-01 12:00:00] = Scanner.parse_date("01/01/1990 12:00:00 PM")
    end

  end

end