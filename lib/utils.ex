defmodule LineBot.Utils do
  def string_to_integer(value) do
    try do
      {:ok, String.to_integer(value)}
    catch
      _ ->
        :invalid
    end
  end

  def sha(binary) do
    :crypto.hash(:sha, binary)
  end

  def unique_id_62() do
    rand =
      :erlang.term_to_binary({make_ref(), :os.timestamp()})
      |> sha()

    <<i::160>> = rand
    integer_to_string(i, 62)
  end

  def integer_to_string(i, 10) do
    Integer.to_string(i)
  end

  def integer_to_string(i, base)
      when is_integer(i) and is_integer(base) and base >= 2 and
             base <= 1 + ?Z - ?A + 10 + 1 + ?z - ?a do
    cond do
      i < 0 ->
        <<?->> <> integer_to_string(-i, base, "")

      true ->
        integer_to_string(i, base, "")
    end
  end

  def integer_to_string(i, base) do
    raise(ArgumentError, "#{inspect([i, base])}")
  end

  defp integer_to_string(i0, base, r0) do
    d = rem(i0, base)
    i1 = div(i0, base)

    r1 =
      cond do
        d >= 36 ->
          <<d - 36 + ?a>> <> r0

        d >= 10 ->
          <<d - 10 + ?A>> <> r0

        true ->
          <<d + ?0>> <> r0
      end

    cond do
      i1 === 0 -> r1
      true -> integer_to_string(i1, base, r1)
    end
  end
end
