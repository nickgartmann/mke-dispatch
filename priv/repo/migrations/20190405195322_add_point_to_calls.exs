defmodule Mpd.Repo.Migrations.AddPointToCalls do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"
    execute("SELECT AddGeometryColumn ('calls', 'point', 4326, 'POINT', 2)")
  end

  def down do
    alter table(:calls) do
      drop :point
    end
  end

end
