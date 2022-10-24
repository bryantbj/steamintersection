defmodule SteamIntersectionWeb.RoomLive.Root do
  use SteamIntersectionWeb, :live_view

  alias SteamIntersection.Rooms
  alias SteamIntersection.Rooms.Room

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("start", _params, socket) do
    case Rooms.create_room() do
      {:ok, room} ->
        {:noreply, push_redirect(socket, to: Routes.room_show_path(socket, :show, room))}
      {:error, error} ->
        {:noreply, error}
    end
  end
end
