defmodule SteamIntersection.Steam.Profile do
  use HTTPoison.Base

  @cache :app
  @ttl :timer.hours(24)

  def api_key() do
    System.get_env("STEAM_API_KEY")
  end

  def default_options() do
    %{
      format: "json",
      include_appinfo: true,
      key: api_key()
    }
  end

  def base_uri(:profile) do
    "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002"
  end
  def base_uri(:vanity) do
    "http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001"
  end

  def endpoint(query, uri \\ :profile ) when is_map(query) do
    base_uri(uri) <> "?" <> URI.encode_query(query)
  end

  def process_response_body(body) do
    body
    |> Jason.decode!(keys: :atoms)
  end

  def get_profile(steamids, opts \\ default_options())

  def get_profile(steamids, opts) when is_binary(steamids) do
    default_options()
    |> Map.merge(opts)
    |> Map.put(:steamids, steamids)
    |> endpoint()
    |> get()
    |> case do
      {:ok, %{status_code: 200, body: %{response: body}}} ->
        {:ok, body}
      other ->
        other
    end
  end

  def get_profile_cache(steamids, opts \\ default_options()) do
    key = cache_key(String.trim(steamids))

    Cachex.execute!(@cache, fn cache ->
      resp =
        Cachex.fetch(cache, key, fn ->
          {:ok, %{players: body}} = get_profile(steamids, opts)
          body
        end)
        |> case do
          {:commit, players} -> {:ok, players}
          {:ok, players} -> {:ok, players}
          {other, msg} -> {other, msg}
        end

      Cachex.expire(cache, key, @ttl)

      resp
    end)
  end

  def resolve_vanity_url(vanityurl) do
    default_options()
    |> Map.put(:vanityurl, vanityurl)
    |> endpoint(:vanity)
    |> get()
    |> case do
      {:ok, %{status_code: 200, body: %{response: %{success: _, steamid: id}}}} -> {:ok, id}
      other -> other
    end
  end

  defp cache_key(steamids) do
    "#{@cache}:profile:#{steamids}"
  end
end
