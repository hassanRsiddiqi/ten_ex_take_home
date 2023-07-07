defmodule TenExTakeHomeWeb.DataLive do
  @moduledoc """
  List data from characters api.
  """
  use TenExTakeHomeWeb, :live_view
  alias TenExTakeHome.External.Marvel.Cache

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    characters =
      case Cache.get_characters() do
        {:ok, characters} -> characters
        {:error, _error_message} -> %{"results" => %{}}
      end

    {:noreply, assign(socket, characters: characters)}
  end
end
