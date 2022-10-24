defmodule SteamIntersectionWeb.RoomLive.Show do
  use SteamIntersectionWeb, :live_view

  alias SteamIntersection.{Rooms, Steam.Profile}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:room, Rooms.get_room!(id))
     |> assign(:steamids, [])
     |> assign(:profiles, [])}
  end

  @impl true
  def handle_event("validate", %{"search" => params}, socket) do
    IO.inspect(params, label: "search params")

    {:noreply, socket}
  end

  def handle_event("add", %{"search" => %{"q" => id}}, socket) do
    add_id_and_fetch_profile(socket, id)
  end

  defp add_id_and_fetch_profile(socket, id) do
    {:ok, [profile]} =
      parse_id(id)
      |> Profile.get_profile_cache()

    {:noreply,
     socket
     |> assign(:steamids, [id | socket.assigns.steamids])
     |> assign(:profiles, [profile | socket.assigns.profiles])}
  end

  defp parse_id(given_id) do
    given_id = String.trim(given_id)

    cond do
      String.match?(given_id, ~r{http.+}) ->
        [[val]] = Regex.scan(~r{(?:id|profiles)/(\w+)}, given_id, capture: :all_but_first)
        parse_id(val)

      String.match?(given_id, ~r{[a-zA-Z]+}) ->
        {:ok, val} = Profile.resolve_vanity_url(given_id)
        parse_id(val)

      String.match?(given_id, ~r{\d+}) ->
        given_id
    end
  end

  defp page_title(:show), do: "Show Room"
  defp page_title(:edit), do: "Edit Room"
end
