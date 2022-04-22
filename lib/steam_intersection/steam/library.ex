defmodule SteamIntersection.Steam.Library do
  use HTTPoison.Base

  def api_key() do
    System.get_env("STEAM_API_KEY")
  end
end
