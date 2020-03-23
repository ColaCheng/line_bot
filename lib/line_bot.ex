defmodule LineBot do
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    mongodb_url = Application.fetch_env!(:line_bot, :mongodb_url)

    children = [
      worker(Mongo, [[name: :mongo, url: mongodb_url]]),
      worker(LineBot.InternalServer, []),
      worker(LineBot.CowboyServer, []),
      worker(LineBot.PharmaciesCache, [[]])
    ]

    opts = [strategy: :one_for_one, name: LineBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
