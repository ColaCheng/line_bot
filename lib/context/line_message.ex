defmodule LineBot.Context.LineMessage do
  require Logger

  @line_reply_url "https://api.line.me/v2/bot/message/reply"
  @headers [{"Content-Type", "application/json"}]
  def reply(reply_token, texts) do
    messages = for text <- texts, do: %{type: "text", text: text}
    reply_body = %{replyToken: reply_token, messages: messages} |> :jiffy.encode()

    headers = [
      {"Authorization", "Bearer #{Application.fetch_env!(:line_bot, :access_token)}"} | @headers
    ]

    case :hackney.request(:post, @line_reply_url, headers, reply_body, []) do
      {:ok, 200, _} ->
        :ok

      {:ok, 200, _, _} ->
        :ok

      {:ok, status, headers, ref} ->
        Logger.info(
          "Reply to Line error, status: #{inspect(status)}, headers: #{inspect(headers)}, body: #{
            inspect(:hackney.body(ref))
          }"
        )

        :error

      {:error, reason} ->
        Logger.error("Reply to Line error, reason: #{inspect(reason)}")
        :error
    end
  end
end
