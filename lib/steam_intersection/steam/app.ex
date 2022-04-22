defmodule SteamIntersection.Steam.App do
  defstruct [:appid, :img_icon_url, :img_header_url, :name, :playtime_forever]
  use ExConstructor

  def icon_base_uri() do
    "https://media.steampowered.com/steamcommunity/public/images/apps"
  end

  def header_base_uri() do
    "https://cdn.akamai.steamstatic.com/steam/apps"
  end

  def img_icon_url(%{appid: id, img_icon_url: hash} = game) when is_map(game) do
    icon_base_uri() <> "/#{id}/#{hash}.jpg"
  end

  def img_header_url(%{appid: id} = game) when is_map(game) do
    header_base_uri() <> "/#{id}/header.jpg"
  end

  def build(map) do
    app = new(map)

    app
    |> Map.put(:img_icon_url, img_icon_url(app))
    |> Map.put(:img_header_url, img_icon_url(app))
  end
end
