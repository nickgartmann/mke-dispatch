defmodule Mpd.Repo.Migrations.CallsNotify do
  use Ecto.Migration

  def up do
    """
    CREATE OR REPLACE FUNCTION notify_call_changes()
    RETURNS trigger AS $$
    BEGIN
      PERFORM pg_notify(
        'calls_changed',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """
    |> execute()

    """
    CREATE TRIGGER calls_changed
    AFTER INSERT OR UPDATE
    ON calls
    FOR EACH ROW
    EXECUTE PROCEDURE notify_call_changes();
    """
    |> execute()
  end

  def down do
    execute "DROP TRIGGER calls_changed ON calls;"
    execute "DROP FUNCTION notify_call_changes;"
  end
end
