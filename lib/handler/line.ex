defmodule LineBot.Handler.Line do
  require Logger
  alias LineBot.Handler.Utils, as: HUtils

  def init(req_in, opts) do
    request = %{
      method: :cowboy_req.method(req_in),
      data: %{}
    }

    Logger.info("headers: #{inspect(:cowboy_req.headers(req_in))}")

    {result, req_done} =
      case :cowboy_req.has_body(req_in) do
        true ->
          {:ok, body, req_out} = HUtils.read_body(req_in, <<>>)

          case HUtils.decode_body(body, :json) do
            {:ok, data} ->
              Logger.info("body: #{inspect(data)}")
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
        parse_line_events(events)
        {:ok, %{message: "ok"}}

      _ ->
        :method_not_allowed
    end
  end

  defp process_request(_) do
    :invalid_line_event
  end

  @line_reply_url "https://api.line.me/v2/bot/message/reply"
  @headers [{"Content-Type", "application/json"}, {"Authorization", "Bearer #{Application.fetch_env!(:line_bot, :access_token)}"}]
  defp parse_line_events([]), do: :ok
  defp parse_line_events([%{"type" => "message", "replyToken" => reply_token, "message" => %{"text" => input_txt, "type" => "text"}} | tail]) do
    reply_body = %{replyToken: reply_token, messages: [%{type: "text", text: input_txt}]} |> :jiffy.encode()
    Logger.info("reply_body: #{inspect reply_body}")
    case :hackney.request(:post, @line_reply_url, @headers, reply_body, []) do
      {:ok, 200, _} ->
        parse_line_events(tail)

      {:ok, 200, _, _} ->
        parse_line_events(tail)

      {:ok, status, headers, _} ->
        Logger.error("status: #{inspect status}, headers: #{inspect headers}")
        parse_line_events(tail)
      {:error, reason} ->
        Logger.error("Reply to Line error: #{inspect reason}")
        parse_line_events(tail)
    end
  end
  defp parse_line_events([_ | tail]) do
    parse_line_events(tail)
  end

  defp make_response({:ok, result}), do: {200, result}
  defp make_response(:invalid_json), do: {400, %{message: "Invalid JSON."}}
  defp make_response(:invalid_line_event), do: {400, %{message: "Invalid Line event."}}
  defp make_response(:method_not_allowed), do: {405, %{message: "Method not allowed."}}
end
