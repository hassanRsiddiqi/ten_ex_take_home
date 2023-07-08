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

  @spec get_characters(pid() | String.t()) :: {:ok, map()} | {:error, atom()} | {:errpr, map()}
  def get_characters(server \\ __MODULE__) do
    GenServer.call(server, :get)
  end

  # private functions
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    Logger.info("Marvel Cache process initalized")
    {:ok, :no_data}
  end

  def handle_call(:get, _from, :no_data) do
    Logger.info("No data found. Fetching data from the Marvel API.")
    request_data()
  end

  def handle_call(:get, _from, {:error, error}) do
    Logger.error("Error encountered: #{inspect(error)}. Fetching data from the Marvel API.")
    request_data()
  end

  def handle_call(:get, _from, {:ok, _characters} = state) do
    Logger.info("Fetching data from the Marvel cache.")
    {:reply, state, state}
  end

  defp request_data() do
    response = Marvel.get_characters()

    # create stats
    insert_stats(response)

    case response do
      {:ok, _characters} ->
        Logger.info("Successfully fetched data from the Marvel API.")

      {:error, error} ->
        Logger.error("Error encountered during data retrieval: #{inspect(error)}")
    end

    {:reply, response, response}
  end

  defp insert_stats({:ok, _characters}) do
    Stats.create(%{status: "success"})
  end

  defp insert_stats({:error, _error}) do
    Stats.create(%{status: "error"})
  end
end
