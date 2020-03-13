defmodule LineBot.Handler.Utils do
  def read_body(req_in, acc) do
    case :cowboy_req.read_body(req_in) do
      {:ok, data, req} ->
        {:ok, <<acc::binary, data::binary>>, req}

      {:more, data, req} ->
        read_body(req, <<acc::binary, data::binary>>)
    end
  end

  def decode_body(body, :json) do
    try do
      {:ok, :jiffy.decode(body, [:return_maps])}
    catch
      _ ->
        :error
    end
  end
end
