defmodule TenExTakeHome.Stats do
  @moduledoc """
  The handy functions to access stats table.
  """
  import Ecto.Query, warn: false

  alias TenExTakeHome.Repo
  alias TenExTakeHome.Stats.Stat

  def create(attrs \\ %{}) do
    %Stat{}
    |> Stat.changeset(attrs)
    |> Repo.insert()
  end
end
