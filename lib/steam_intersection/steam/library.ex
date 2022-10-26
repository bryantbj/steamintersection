defmodule SteamIntersection.Steam.Library do
  use HTTPoison.Base
  alias SteamIntersection.Steam.App

  @cache :app
  @ttl :timer.minutes(10)

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

  def base_uri() do
    "https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001"
  end

  def endpoint(query) when is_map(query) do
    base_uri() <> "?" <> URI.encode_query(query)
  end

  def process_response_body(body) do
    body
    |> Jason.decode!(keys: :atoms)
  end

  @doc """
  Given a player `steamid`, fetch a json list of
  all the games that player owns.
  """
  def get_owned_games(steamid, opts \\ default_options())

  def get_owned_games(steamid, opts) when is_integer(steamid) do
    steamid
    |> Integer.to_string()
    |> get_owned_games(opts)
  end

  def get_owned_games(steamid, opts) when is_binary(steamid) do
    default_options()
    |> Map.merge(opts)
    |> Map.put(:steamid, steamid)
    |> endpoint()
    |> get()
    |> case do
      {:ok, %{status_code: 200, body: %{response: %{games: games} = body}}} ->
        body = Map.put(body, :games, Enum.map(games, & App.build(&1)))
        {:ok, body}

      {:ok, %{status_code: 200, body: %{response: _}}} ->
        {:error, "profile is private"}


      {:error, err} ->
        {:error, err}

      other ->
        other
    end
  end

  def get_owned_games_cache(steamid, opts \\ default_options()) do
    Cachex.execute(@cache, fn cache ->
      resp = Cachex.fetch(cache, String.trim(steamid), fn key ->
        {:commit, get_owned_games(key, opts)}
      end)

      Cachex.expire(cache, steamid, @ttl)

      resp
    end)
  end

  def get_intersection(steam_ids) when is_list(steam_ids) do
    data = steam_ids
    |> Enum.map(fn id ->
      Task.Supervisor.async_nolink(SteamIntersection.TaskSupervisor, fn -> {id, get_owned_games(id)} end)
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.filter(fn {_, {msg, _}} -> msg == :ok end)
    |> Enum.map(fn {id, {_, %{games: games}}} -> {id, games} end)
    |> Enum.reduce(%{all: %{}, intersection: MapSet.new}, fn {_id, games}, acc ->
      game_ids = Enum.map(games, & &1.appid) |> Enum.into(MapSet.new)

      case MapSet.size(acc.intersection) do
        0 ->
          acc = Map.put(acc, :all, Enum.reduce(games, acc.all, fn game, all ->
            Map.put_new(all, game.appid, game)
          end))
          %{acc|intersection: game_ids}
        _ ->
          acc = Map.put(acc, :all, Enum.reduce(games, acc.all, fn game, all ->
            Map.put_new(all, game.appid, game)
          end))

          %{acc|intersection: MapSet.intersection(game_ids, acc.intersection)}
      end
    end)

    Enum.map(data.intersection, & Map.get(data.all, &1))
  end
end
