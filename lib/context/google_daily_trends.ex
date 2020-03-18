defmodule LineBot.Context.GoogleDailyTrends do
  require Logger
  alias LineBot.Context.ShortUrl

  @default_title "看看今天大家都在搜什麼呢？🔥🔥🔥\n\n"

  def get(geo) do
    case ExTrends.DailyTrends.request(geo) |> ExTrends.run() do
      {:ok, [topic1, topic2, topic3 | _]} ->
        base_url = Application.fetch_env!(:line_bot, :base_url)

        %{
          "title" => %{"query" => t1_query},
          "articles" => [%{"title" => t1_title, "url" => t1_url} | _]
        } = topic1

        %{
          "title" => %{"query" => t2_query},
          "articles" => [%{"title" => t2_title, "url" => t2_url} | _]
        } = topic2

        %{
          "title" => %{"query" => t3_query},
          "articles" => [%{"title" => t3_title, "url" => t3_url} | _]
        } = topic3

        [
          @default_title,
          [
            "💡 ",
            t1_query,
            " 🔎\n",
            "🗞️ ",
            t1_title,
            "\n",
            make_short_url(t1_url, base_url)
          ],
          "\n\n",
          [
            "💡 ",
            t2_query,
            " 🔎\n",
            "🗞️ ",
            t2_title,
            "\n",
            make_short_url(t2_url, base_url)
          ],
          "\n\n",
          [
            "💡 ",
            t3_query,
            " 🔎\n",
            "🗞️ ",
            t3_title,
            "\n",
            make_short_url(t3_url, base_url)
          ]
        ]
        |> IO.iodata_to_binary()

      {:error, reason} ->
        Logger.error("Google daily trends API error: #{inspect(reason)}")
        ""
    end
  end

  defp make_short_url(url, base_url) do
    case ShortUrl.create(url) do
      {:ok, hash_id} -> <<base_url::binary, ?/, hash_id::binary>>
      _ -> url
    end
  end
end
