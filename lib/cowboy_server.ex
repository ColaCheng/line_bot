defmodule LineBot.CowboyServer do
  use GenServer

  @mongo_server :mongo
  @short_url_coll "shortUrl"

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    init_indexes()

    dispatch =
      :cowboy_router.compile([
        {
          :_,
          [
            {"/:hash_id", LineBot.Handler.Redirect, []},
            {"/line/webhook", LineBot.Handler.Line, []}
          ]
        }
      ])

    port = Application.fetch_env!(:line_bot, :port)
    ssl? = Application.fetch_env!(:line_bot, :ssl)
    cacertfile = Application.fetch_env!(:line_bot, :cacertfile)
    certfile = Application.fetch_env!(:line_bot, :certfile)
    keyfile = Application.fetch_env!(:line_bot, :keyfile)
    socket_opts = [port: port]
    transport_opts = %{socket_opts: socket_opts, max_connections: 16_384, num_acceptors: 100}
    protocol_opts = %{env: %{dispatch: dispatch}}

    case ssl? do
      true ->
        cert_opts = [cacertfile: cacertfile, certfile: certfile, keyfile: keyfile]

        {:ok, _} =
          :cowboy.start_tls(
            :https,
            Map.put(transport_opts, :socket_opts, socket_opts ++ cert_opts),
            protocol_opts
          )

      false ->
        {:ok, _} = :cowboy.start_clear(:http, transport_opts, protocol_opts)
    end
  end

  defp init_indexes() do
    Mongo.create_indexes(
      @mongo_server,
      @short_url_coll,
      [
        [{"key", [{"hash_id", 1}]}, {"name", "hash_id"}]
      ],
      [{"unique", 1}]
    )
  end
end
