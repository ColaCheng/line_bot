defmodule LineBot.Context.LineMessage do
  require Logger
  alias LineBot.Request

  @line_reply_url "https://api.line.me/v2/bot/message/reply"
  @headers [{"Content-Type", "application/json"}]
  def reply(_, []), do: :ok

  def reply(reply_token, texts) do
    messages = for text <- texts, do: %{type: "text", text: text}
    reply_body = %{replyToken: reply_token, messages: messages} |> :jiffy.encode()

    headers = [
      {"Authorization", "Bearer #{Application.fetch_env!(:line_bot, :access_token)}"} | @headers
    ]

    case Request.request(:post, @line_reply_url, reply_body, headers, []) do
      {:ok, %{status_code: 200}} ->
        :ok

      {:ok, response} ->
        Logger.info("Reply to Line error, response: #{inspect(response)}}")

        :error

      {:error, reason} ->
        Logger.error("Reply to Line error, reason: #{inspect(reason)}")
        :error
    end
  end
end
