defmodule LineBot.Handler.Line do
  require Logger
  alias LineBot.Handler.Utils, as: HUtils
  alias LineBot.Context.LineMessage

  def init(req_in, opts) do
    request = %{
      method: :cowboy_req.method(req_in),
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

  defp process_request(%{method: method, data: %{"events" => events}}) do
    case method do
      "POST" ->
        process_line_events(events)
        {:ok, %{message: "ok"}}

      _ ->
        :method_not_allowed
    end
  end

  defp process_request(_) do
    :invalid_line_event
  end

  defp process_line_events([]), do: :ok

  defp process_line_events([
         %{
           "type" => "message",
           "replyToken" => reply_token,
           "message" => %{"text" => input_txt, "type" => "text"}
         }
         | tail
       ]) do
    LineMessage.reply(reply_token, [input_txt])
    process_line_events(tail)
  end

  defp process_line_events([_ | tail]) do
    process_line_events(tail)
  end

  defp make_response({:ok, result}), do: {200, result}
  defp make_response(:invalid_json), do: {400, %{message: "Invalid JSON."}}
  defp make_response(:invalid_line_event), do: {400, %{message: "Invalid Line event."}}
  defp make_response(:method_not_allowed), do: {405, %{message: "Method not allowed."}}
end
