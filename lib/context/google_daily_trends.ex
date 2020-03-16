defmodule LineBot.Handler.GoogleDailyTrends do

  def get(geo) do
    ExTrends.DailyTrends.request(geo) |> ExTrends.run()
  end
end
