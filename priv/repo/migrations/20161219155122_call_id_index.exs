defmodule MkePolice.Repo.Migrations.CallIdIndex do
  use Ecto.Migration

  def change do
    create index(:calls, [:call_id])
  end
end
