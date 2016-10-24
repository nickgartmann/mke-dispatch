defmodule MkePolice.Repo.Migrations.AddLatLngToCall do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"
    execute("SELECT AddGeometryColumn ('calls', 'point', 4326, 'POINT', 2)")
  end

  def down do 
    execute "DROP EXTENSION IF EXISTS postgis"
  end
end
