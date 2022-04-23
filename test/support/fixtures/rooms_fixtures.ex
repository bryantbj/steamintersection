defmodule SteamIntersection.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SteamIntersection.Rooms` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        public_id: "some public_id"
      })
      |> SteamIntersection.Rooms.create_room()

    room
  end
end
