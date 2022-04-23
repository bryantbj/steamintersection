defmodule SteamIntersection.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :public_id, :string, null: false

      timestamps()
    end

    create index(:rooms, [:public_id])
  end
end
