defmodule MkePolice.CallTest do
  use MkePolice.ModelCase

  alias MkePolice.Call

  @valid_attrs %{district: 42, location: "some content", nature: "some content", status: "some content", time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Call.changeset(%Call{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Call.changeset(%Call{}, @invalid_attrs)
    refute changeset.valid?
  end
end
