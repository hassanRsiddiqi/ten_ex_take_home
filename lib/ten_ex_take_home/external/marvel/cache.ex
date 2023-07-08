defmodule TenExTakeHome.External.Marvel.Cache do
  @moduledoc """
  We will use a GenServer to store data retrieved from the Marvel API.
  This GenServer will serve as the source of truth for our LiveView component.
  All requests from the LiveView to fetch data from the Marvel client will
  go through this GenServer.
  """
  use GenServer

  require Logger
  alias TenExTakeHome.External.Marvel
  alias TenExTakeHome.Stats

  defp default_pagination_limit(),
    do: Application.fetch_env!(:ten_ex_take_home, :default_pagination_limit)

  @spec get_characters(pid() | String.t()) :: {:ok, map()} | {:error, atom()} | {:errpr, map()}
  def get_characters(params \\ %{}, server \\ __MODULE__) do
    GenServer.call(server, {:get, params})
  end

  @spec state(pid() | String.t()) :: map()
  def state(server) do
    GenServer.call(server, :state)
  end

  # private functions
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    Logger.info("Marvel Cache process initalized")
    {:ok, %{characters: %{}}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get, params}, _from, %{characters: %{}} = state) do
    Logger.info("No data found. Fetching data from the Marvel API.")

    case call_client(params) do
      {:ok, characters} = response ->
        {:reply, response, %{characters: [characters]}}

      {:error, _error} = response ->
        {:reply, response, state}
    end
  end

  def handle_call({:get, params}, _from, %{characters: characters} = state) do
    case maybe_request_data(characters, params) do
      {:api, response} ->
        {:reply, {:ok, response}, %{characters: [response | characters]}}

      {:cache, response} ->
        {:reply, {:ok, response}, state}
    end
  end

  defp maybe_request_data(characters, params) do
    limit = Map.get(params, :limit, default_pagination_limit())
    offset = Map.get(params, :offset, 0)

    Enum.find(characters, nil, fn character ->
      character["limit"] == limit and character["offset"] == offset
    end)
    |> case do
      nil ->
        {:ok, response} = call_client(params)
        {:api, response}

      data ->
        {:cache, data}
    end
  end

  defp call_client(params) do
    response = Marvel.get_characters(params)

    case response do
      {:ok, _characters} ->
        Stats.create(%{status: "success"})
        Logger.info("Successfully fetched data from the Marvel API.")

      {:error, error} ->
        Stats.create(%{status: "error"})
        Logger.error("Error encountered during data retrieval: #{inspect(error)}")
    end

    response
  end
end
