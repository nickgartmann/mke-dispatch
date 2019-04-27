defmodule Mpd.Repo.Migrations.CreateCalls do
  use Ecto.Migration

  def change do
    create table(:calls) do
      add :time, :naive_datetime
      add :location, :string
      add :district, :string
      add :nature, :string
      add :status, :string
      add :call_id, :string

      timestamps()
    end

  end
end
