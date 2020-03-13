defmodule LineBot.CowboyServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    dispatch =
      :cowboy_router.compile([
        {
          :_,
          [
            {"/", LineBot.Handler.Example, []}
          ]
        }
      ])

    port = Application.fetch_env!(:line_bot, :port)
    {:ok, _} = :cowboy.start_clear(:http, [port: port], %{env: %{dispatch: dispatch}})
  end
end
