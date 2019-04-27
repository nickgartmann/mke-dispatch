Postgrex.Types.define(Mpd.PostgresTypes,
      [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
      json: Jason)
