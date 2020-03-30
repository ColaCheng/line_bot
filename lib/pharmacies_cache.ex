defmodule LineBot.PharmaciesCache do
  use GenServer
  require Logger
  alias LineBot.Request

  @ets_table :pharmacies
  @pharmacies_info_url "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json"
  @interval 5 * 60 * 1_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get() do
    case :ets.lookup(@ets_table, :pharmacies_info) do
      [pharmacies_info: pharmacies_info] -> {:ok, pharmacies_info}
      [] -> {:error, :notfound}
    end
  end

  @impl true
  def init(_) do
    @ets_table =
      :ets.new(@ets_table, [:named_table, write_concurrency: true, read_concurrency: true])

    send(self(), :timeout)
    {:ok, []}
  end

  @impl true
  def handle_info(:timeout, state) do
    case Request.request(:get, @pharmacies_info_url) do
      {:ok, %{status_code: 200, body: body}} ->
        pharmacies_info =
          :jiffy.decode(body, [:return_maps])
          |> Map.get("features")

        :ets.insert(@ets_table, {:pharmacies_info, pharmacies_info})

      {:ok, other} ->
        Logger.info("Get pharmacies info have some problem: #{inspect(other)}")
        Process.send_after(self(), :timeout, 10_000)

      {:error, error} ->
        Logger.error("Get pharmacies info error: #{inspect(error)}")
        Process.send_after(self(), :timeout, 10_000)
    end

    {:noreply, state, @interval}
  end
end
