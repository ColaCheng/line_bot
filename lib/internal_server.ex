defmodule LineBot.InternalServer do
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
            {"/", LineBot.Handler.Health, []}
          ]
        }
      ])

    transport_opts = %{port: 4001, max_connections: 16_384, num_acceptors: 10}
    protocol_opts = %{env: %{dispatch: dispatch}}
    {:ok, _} = :cowboy.start_clear(:internal_http, transport_opts, protocol_opts)
  end
end
