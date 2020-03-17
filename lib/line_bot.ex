defmodule LineBot do
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      worker(LineBot.InternalServer, []),
      worker(LineBot.CowboyServer, [])
    ]

    opts = [strategy: :one_for_one, name: LineBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
