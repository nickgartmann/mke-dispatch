defmodule MkePolice.Repo.Migrations.CreateCall do
  use Ecto.Migration

  def change do
    create table(:calls) do
      add :time, :datetime
      add :location, :text
      add :district, :integer
      add :nature, :text
      add :status, :text

      timestamps()
    end

  end
end
