defmodule SteamIntersection.Steam do
  use HttPoison.Base

  def api_key() do
    System.get_env("STEAM_API_KEY")
  end

  def process_request_url(url) do
  end
end
