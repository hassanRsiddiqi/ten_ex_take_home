defmodule TenExTakeHome.Stats.Stat do
  @moduledoc """
  Schema for stats table.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @optional ~w()a
  @required ~w(status)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "stats" do
    field :status, Ecto.Enum, values: [:success, :error]

    timestamps()
  end

  def changeset(stats, attrs) do
    stats
    |> cast(attrs, @optional ++ @required)
    |> validate_required(@required)
  end
end
