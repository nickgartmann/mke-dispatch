defmodule MkePolice.Repo.Migrations.CallIdField do
  use Ecto.Migration

  def change do
    alter table(:calls) do
      add :call_id, :string
    end
  end
end
