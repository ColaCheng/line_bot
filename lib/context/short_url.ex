defmodule LineBot.Context.ShortUrl do
  require Logger
  alias LineBot.Utils

  @hash_id_size 8
  @mongo_server :mongo
  @collection "shortUrl"

  def get(hash_id) when byte_size(hash_id) === 8 do
    case Mongo.find_one_and_update(
           @mongo_server,
           @collection,
           %{hash_id: hash_id},
           %{"$inc" => %{"hit" => 1}},
           []
         ) do
      {:ok, %{"url" => url}} ->
        {:ok, url}

      {:ok, nil} ->
        {:error, :notfound}

      error ->
        Logger.error("Get shortUrl error: #{inspect(error)}")
        {:error, :notfound}
    end
  end

  def get(_) do
    {:error, :invalid}
  end

  def create(url) do
    <<hash_id::binary-size(@hash_id_size), _::binary>> = Utils.unique_id_62()

    case Mongo.insert_one(@mongo_server, @collection, %{hash_id: hash_id, url: url}) do
      {:ok, _} ->
        {:ok, hash_id}

      {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000}]}} ->
        {:error, :duplicate}

      error ->
        error
    end
  end
end
