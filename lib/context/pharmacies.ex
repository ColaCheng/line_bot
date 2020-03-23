defmodule LineBot.Context.Pharmacies do
  require Logger
  alias LineBot.PharmaciesCache

  def find_near_pharmacies(point) do
    case PharmaciesCache.get() do
      {:ok, pharmacies} ->
        for %{"geometry" => %{"coordinates" => [p_lat, p_long]}} = pharmacy <- pharmacies do
          Map.put(pharmacy, "distance", haversine(point, {p_lat, p_long}))
        end
        |> Enum.sort(&(Map.get(&1, "distance") <= Map.get(&2, "distance")))
        |> Enum.take(5)

      {:error, reason} ->
        Logger.error("Pharmacies cache error: #{inspect(reason)}")
    end
  end

  @v :math.pi() / 180
  # km for the earth radius
  @r 6372.8
  defp haversine({lat1, long1}, {lat2, long2}) do
    dlat = :math.sin((lat2 - lat1) * @v / 2)
    dlong = :math.sin((long2 - long1) * @v / 2)
    a = dlat * dlat + dlong * dlong * :math.cos(lat1 * @v) * :math.cos(lat2 * @v)
    @r * 2 * :math.asin(:math.sqrt(a))
  end
end
