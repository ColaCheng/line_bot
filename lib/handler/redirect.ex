defmodule LineBot.Handler.Redirect do
  require Logger
  alias LineBot.Context.ShortUrl

  @base_headers %{"content-type" => "text/plain"}

  def init(req_in, opts) do
    request = %{
      method: :cowboy_req.method(req_in),
      hash: :cowboy_req.binding(:hash, req_in)
    }

    case process_request(request) |> make_response() do
      {301, url} ->
        {:ok,
         :cowboy_req.reply(
           301,
           %{"location" => url},
           "",
           req_in
         ), opts}

      {code, response} ->
        {:ok,
         :cowboy_req.reply(
           code,
           @base_headers,
           response,
           req_in
         ), opts}

      code ->
        {:ok, :cowboy_req.reply(code, req_in), opts}
    end
  end

  defp process_request(%{method: method, hash: hash}) do
    case method do
      "GET" ->
        get_redirect_url(hash)

      _ ->
        :method_not_allowed
    end
  end

  defp get_redirect_url(hash) do
    case ShortUrl.get(hash) do
      {:ok, url} -> {:redirect, url}
      {:error, :notfound} -> :notfound
    end
  end

  defp make_response({:redirect, url}), do: {301, url}
  defp make_response(:notfound), do: {400, "Url notfound"}
  defp make_response(:method_not_allowed), do: {405, "Method not allowed."}
end
