defmodule TenExTakeHome.MarvelCacheSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      TenExTakeHome.External.Marvel.Cache
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
