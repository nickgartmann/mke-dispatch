Postgrex.Types.define(MkePolice.PostgresTypes,
      [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
      json: Poison)
