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
    protocol_opts = %{env: %{dispatch: dispatch}}

    case ssl? do
      true ->
        {:ok, _} =
          :cowboy.start_tls(
            :https,
            [
              port: port,
              cacertfile: cacertfile,
              certfile: certfile,
              keyfile: keyfile
            ],
            protocol_opts
          )

      false ->
        {:ok, _} = :cowboy.start_clear(:http, [port: port], protocol_opts)
    end
  end
end
