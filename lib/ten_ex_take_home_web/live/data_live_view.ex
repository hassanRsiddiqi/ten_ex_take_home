defmodule TenExTakeHomeWeb.DataLive do
  @moduledoc """
  List data from characters api.
  """
  use TenExTakeHomeWeb, :live_view
  alias TenExTakeHome.External.Marvel.Cache
  alias TenExTakeHome.External.Marvel

  @pagination_limit 10

  def mount(_params, _session, socket) do
    {:ok, assign(socket, limit: 10, offset: 0)}
  end

  def handle_params(_params, _uri, socket) do
    characters = get_characters()

    {:noreply, assign(socket, characters: characters)}
  end

  def handle_event("next", _value, socket) do
    limit = socket.assigns.limit
    offset = socket.assigns.offset + default_pagination_limit()

    characters = get_characters(%{limit: limit, offset: offset})
    {:noreply, assign(socket, characters: characters, limit: limit, offset: offset)}
  end

  def handle_event("previous", _value, socket) do
    limit = socket.assigns.limit
    offset = socket.assigns.offset - default_pagination_limit()

    characters = get_characters(%{limit: limit, offset: offset})
    {:noreply, assign(socket, characters: characters, limit: limit, offset: offset)}
  end

  defp get_characters(params \\ %{}) do
    case Cache.get_characters(params) do
      {:ok, characters} -> characters
      {:error, _error_message} -> %{"results" => %{}}
    end
  end

  defp default_pagination_limit(), do: Application.fetch_env!(:ten_ex_take_home, :default_pagination_limit)
end
