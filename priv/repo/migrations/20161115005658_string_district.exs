defmodule MkePolice.Repo.Migrations.StringDistrict do
  use Ecto.Migration

  def change do
    alter table(:calls) do
      modify :district, :string
    end
  end
end
