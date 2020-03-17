defmodule LineBot.Context.ShortUrl do
  require Logger
  alias LineBot.Utils

  @hash_id_size 8

  def get(hash_id) when byte_size(hash_id) === 8 do
    {:ok, "https://google.com"}
  end

  def get(_) do
    {:error, :invalid}
  end

  def create(_url) do
    <<hash_id::binary-size(@hash_id_size), _::binary>> = Utils.unique_id_62()
    hash_id
  end
end
