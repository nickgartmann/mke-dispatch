defmodule MkePolice.Repo.Migrations.CallIdIndex do
  use Ecto.Migration

  def change do
    create index(:calls, [:call_id])
    create index(:calls, ["call_id, time DESC, inserted_at DESC"])
  end
end
