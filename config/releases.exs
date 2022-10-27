import Config

# Set ports based on env vars in the release
config :steam_intersection SteamIntersectionWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("HTTP_PORT"))],
  https: [port: String.to_integer(System.get_env("HTTPS_PORT"))]
