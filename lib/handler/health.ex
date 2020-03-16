defmodule LineBot.Handler.Health do
  require Logger

  def init(req_in, opts) do
    {status, result} =
      case :cowboy_req.method(req_in) do
        "GET" ->
          {200, "ok"}

        _ ->
          {405, "Method not allowed."}
      end

    {:ok, :cowboy_req.reply(status, %{}, result, req_in), opts}
  end
end
