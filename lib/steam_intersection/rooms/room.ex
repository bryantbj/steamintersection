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

  def gen_public_id(steamid) do
    [
      Time.utc_now() |> Time.to_string,
      ".",
      to_string(steamid)
    ]
    |> Enum.join()
    |> Base.encode64(padding: false)
  end
end
