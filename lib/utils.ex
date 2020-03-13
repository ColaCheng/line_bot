defmodule LineBot.Utils do
  def string_to_integer(value) do
    try do
      {:ok, String.to_integer(value)}
    catch
      _ ->
        :invalid
    end
  end
end
