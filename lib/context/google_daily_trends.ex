defmodule LineBot.Context.GoogleDailyTrends do
  require Logger
  alias LineBot.Context.ShortUrl

  @default_title "看看今天大家都在搜什麼呢？🔥🔥🔥\n\n"

  def get(geo) do
    case ExTrends.DailyTrends.request(geo) |> ExTrends.run() do
      {:ok, trends} ->
        base_url = Application.fetch_env!(:line_bot, :base_url)

        case get_top3_topics(trends, base_url, []) |> Enum.reverse() do
          [_ | topics] ->
            IO.iodata_to_binary([@default_title, topics])

          [] ->
            IO.iodata_to_binary([@default_title, "現在似乎還沒有資料～"])
        end

      {:error, reason} ->
        Logger.error("Google daily trends API error: #{inspect(reason)}")
        ""
    end
  end

  defp get_top3_topics([], _base_url, acc), do: acc
  defp get_top3_topics(_, _base_url, [_, _, _] = acc), do: acc

  defp get_top3_topics(
         [
           %{
             "title" => %{"query" => query},
             "articles" => [%{"title" => title, "url" => url} | _]
           }
           | tail
         ],
         base_url,
         acc
       ) do
    topic_info = [
      "💡 ",
      query,
      " 🔎\n",
      "🗞️ ",
      title,
      "\n",
      make_short_url(url, base_url)
    ]

    get_top3_topics(tail, base_url, [topic_info, "\n\n" | acc])
  end

  defp make_short_url(url, base_url) do
    case ShortUrl.create(url) do
      {:ok, hash_id} -> <<base_url::binary, ?/, hash_id::binary>>
      _ -> url
    end
  end
end
