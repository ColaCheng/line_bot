defmodule LineBot.Context.ShortUrl do
  require Logger

  def get(_hash) do
    {:ok, "https://google.com"}
  end
end
