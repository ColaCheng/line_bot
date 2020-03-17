defmodule LineBot.Context.GoogleDailyTrends do
  require Logger

  @default_title "看看今天大家都在搜什麼呢？🔥🔥🔥\n\n"

  def get(geo) do
    case ExTrends.DailyTrends.request(geo) |> ExTrends.run() do
      {:ok, [topic1, topic2, topic3 | _]} ->
        %{"articles" => [t1_article | _]} = topic1
        %{"articles" => [t2_article | _]} = topic2
        %{"articles" => [t3_article | _]} = topic3

        [
          @default_title,
          [
            "💡 ",
            topic1["title"]["query"],
            " 🔎\n",
            "🗞️ ",
            t1_article["title"],
            "\n",
            t1_article["url"]
          ],
          "\n\n",
          [
            "💡 ",
            topic2["title"]["query"],
            " 🔎\n",
            "🗞️ ",
            t2_article["title"],
            "\n",
            t2_article["url"]
          ],
          "\n\n",
          [
            "💡 ",
            topic3["title"]["query"],
            " 🔎\n",
            "🗞️ ",
            t3_article["title"],
            "\n",
            t3_article["url"]
          ]
        ]
        |> IO.iodata_to_binary()

      {:error, reason} ->
        Logger.error("Google daily trends API error: #{inspect(reason)}")
        ""
    end
  end
end
