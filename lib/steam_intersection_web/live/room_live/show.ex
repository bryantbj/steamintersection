defmodule SteamIntersectionWeb.RoomLive.Show do
  use SteamIntersectionWeb, :live_view

  alias SteamIntersection.{Rooms, Steam.Profile, Steam.Library}

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
     |> assign(:profiles, [])
     |> assign(:games, [])}
  end

  @impl true
  def handle_event("validate", %{"search" => _params}, socket) do
    {:noreply, socket}
  end

  def handle_event("add", %{"search" => %{"q" => id}}, socket) do
    add_id_and_fetch_profile(socket, id)
  end

  def handle_event("intersect", _, socket) do
    games = Library.get_intersection(socket.assigns.steamids)
            |> Enum.map(fn game ->
              game
              |> Map.put_new(:header_ext, image_extension(game.img_header_url))
              |> Map.put_new(:icon_ext, image_extension(game.img_icon_url))
              |> Map.put_new(:dom_id, game_id(game.name))
            end)
            |> Enum.sort_by(& &1.name)

    {:noreply,
      socket
      |> assign(:games, games)
      |> assign(:filtered, games)
    }
  end

  def handle_event("filter", %{"filter" => %{"q" => query}}, socket) do
    cond do
      String.length(query) == 0 ->
        {:noreply,
          socket
          |> assign(:filtered, socket.assigns.games)
        }
      length(socket.assigns.games) == 0 ->
        {:noreply, socket}
      true ->
        {:noreply,
          socket
          |> assign(:filtered,
            socket.assigns.games
            |> Enum.filter(fn %{name: name} -> String.match?(name, ~r{#{query}}i) end)
            )
        }
    end
  end

  defp add_id_and_fetch_profile(socket, id) do
    {:ok, [profile]} =
      parse_id(id)
      |> Profile.get_profile_cache()

    case profile.steamid in socket.assigns.steamids do
      true ->
        {:noreply, socket}

      false ->
        {:noreply,
         socket
         |> assign(:steamids, [profile.steamid | socket.assigns.steamids])
         |> assign(:profiles, [profile | socket.assigns.profiles])}
    end
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

  defp image_extension(url) do
    scan = Regex.scan(~r{.(\w+)$}, url, capture: :all_but_first)

    case scan do
      [[ext]] -> ext
      other -> other
    end
  end

  defp game_id(name) do
    name
    |> String.replace(~r{[^a-zA-z0-9]}, "-")
    |> String.downcase()
  end

  defp page_title(:show), do: "Show Room"
  defp page_title(:edit), do: "Edit Room"
end
