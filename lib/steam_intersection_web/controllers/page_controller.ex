defmodule SteamIntersectionWeb.PageController do
  use SteamIntersectionWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
