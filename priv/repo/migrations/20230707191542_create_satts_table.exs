defmodule TenExTakeHome.Repo.Migrations.CreateSattsTable do
  use Ecto.Migration

  def change do
    create table(:stats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string

      timestamps()
    end
  end
end
