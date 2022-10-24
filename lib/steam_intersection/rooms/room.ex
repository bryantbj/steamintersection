defmodule SteamIntersection.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :public_id, :string, null: false

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:public_id])
    |> validate_required([:public_id])
  end

  def gen_public_id() do
    Ecto.UUID.generate |> Base.url_encode64
  end
end
