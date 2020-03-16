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
    ssl? = Application.fetch_env!(:line_bot, :ssl)
    cacertfile = Application.fetch_env!(:line_bot, :cacertfile)
    certfile = Application.fetch_env!(:line_bot, :certfile)
    keyfile = Application.fetch_env!(:line_bot, :keyfile)
    transport_opts = %{port: port, max_connections: 16_384, num_acceptors: 100}
    protocol_opts = %{env: %{dispatch: dispatch}}

    case ssl? do
      true ->
        {:ok, _} =
          :cowboy.start_tls(
            :https,
            %{
              cacertfile: cacertfile,
              certfile: certfile,
              keyfile: keyfile
            } |> Map.merge(transport_opts),
            protocol_opts
          )

      false ->
        {:ok, _} = :cowboy.start_clear(:http, transport_opts, protocol_opts)
    end
  end
end
