defmodule LineBot.Handler.Example do
  require Logger
  alias LineBot.Handler.Utils, as: HUtils

  def init(req_in, opts) do
    request = %{
      method: :cowboy_req.method(req_in),
      query: :cowboy_req.parse_qs(req_in),
      data: %{}
    }

    {result, req_done} =
      case :cowboy_req.has_body(req_in) do
        true ->
          {:ok, body, req_out} = HUtils.read_body(req_in, <<>>)

          case HUtils.decode_body(body, :json) do
            {:ok, data} ->
              {process_request(Map.put(request, :data, data)), req_out}

            :error ->
              {:invalid_json, req_out}
          end

        false ->
          {process_request(request), req_in}
      end

    case make_response(result) do
      {code, response} ->
        {:ok,
         :cowboy_req.reply(
           code,
           %{<<"content-type">> => <<"application/json">>},
           :jiffy.encode(response),
           req_done
         ), opts}

      code ->
        {:ok, :cowboy_req.reply(code, req_done), opts}
    end
  end

  defp process_request(%{method: method}) do
    case method do
      "GET" ->
        # Logger.info("Hello World!")
        {:ok, %{message: "Hello World!"}}

      "POST" ->
        :created

      "PUT" ->
        :updated

      "DELETE" ->
        :deleted

      _ ->
        :method_not_allowed
    end
  end

  defp make_response({:ok, result}), do: {200, result}
  defp make_response(:created), do: 201
  defp make_response(:updated), do: 204
  defp make_response(:deleted), do: 205
  defp make_response(:invalid_json), do: {400, %{message: "Invalid JSON."}}
  defp make_response(:method_not_allowed), do: {405, %{message: "Method not allowed."}}
end
