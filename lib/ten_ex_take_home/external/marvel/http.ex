defmodule TenExTakeHome.External.Marvel.HTTP do
  @moduledoc """
  HTTP implementation for Marvel client
  """
  @behaviour TenExTakeHome.External.Marvel

  use Tesla
  require Logger

  @base_url "http://gateway.marvel.com/v1/public/characters"
  @request_data_limit 10

  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.Timeout, timeout: 180_000

  defp public_key(), do: Application.fetch_env!(:ten_ex_take_home, :marvel_public_key)
  defp private_key(), do: Application.fetch_env!(:ten_ex_take_home, :marvel_private_key)
  defp tesla_adapter(), do: Application.fetch_env!(:ten_ex_take_home, :marvel_tesla_adapter)

  adapter(fn env ->
    apply(tesla_adapter(), :call, [
      env,
      [name: __MODULE__, pool: :marvel_pool, max_connections: 50]
    ])
  end)

  @impl Marvel
  def get_characters() do
    case get(url(), headers: headers()) do
      {:ok, %Tesla.Env{status: 200, body: %{"data" => data}}} ->
        {:ok, data}

      {:ok, %Tesla.Env{status: 401, body: %{"code" => code, "message" => message}}} ->
        Logger.error("Marvel API request failed with status 401 #{code}: #{message}")
        {:error, :authorization_error}

      {:ok, %Tesla.Env{status: 429, body: %{"code" => code, "message" => message}}} ->
        Logger.error("Marvel API request failed with status 429 #{code}: #{message}")
        {:error, :limit_surpassed}

      {:ok, %Tesla.Env{status: 409, body: %{"code" => code, "message" => message}}} ->
        Logger.error("Marvel API request failed with status 409 #{code}: #{message}")
        {:error, :unsatisfied_authentication}

      {:ok, %Tesla.Env{status: 403, body: %{"code" => code, "message" => message}}} ->
        Logger.error("Marvel API request failed with status 403 #{code}: #{message}")
        {:error, :forbidden}

      {:ok, %Tesla.Env{status: status, body: %{"code" => code, "message" => message}}} ->
        Logger.error("Marvel API request failed with status #{status} #{code}: #{message}")
        {:error, :internal_server_error}

      {:ok, %Tesla.Env{status: status, body: %{"code" => code, "status" => message}}} ->
        Logger.error("Marvel API request failed with status #{status} #{code}: #{message}")
        {:error, :invalid_data_limit}

      {:error, message} ->
        Logger.error("Marvel API request failed: #{message}")
        {:error, :internal_server_error}
    end
  end

  # private funcations
  defp headers() do
    [
      {"Accept", "application/json"}
    ]
  end

  defp url() do
    ts = :second |> System.system_time() |> Integer.to_string()

    hash =
      :md5 |> :crypto.hash("#{ts}#{private_key()}#{public_key()}") |> Base.encode16(case: :lower)

    authenticated_params =
      "?ts=#{ts}&apikey=#{public_key}&hash=#{hash}&limit=#{@request_data_limit}"

    url = "#{@base_url}#{authenticated_params}"
  end
end
