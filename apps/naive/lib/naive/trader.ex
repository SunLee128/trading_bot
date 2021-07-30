defmodule Naive.Trader do
  use GenServer
  require Logger

  defmodule State do
    @enforce_keys [:profit_interval, :symbol, :tick_size]
    defstruct [
      :buy_order,
      :profit_interval,
      :sell_order,
      :symbol,
      :tick_size
    ]
  end

  def start_link(%{} = args) do
    GenServer.start_link(__MODULE__, args, name: :trader)
  end

  def init(%{symbol: symbol, profit_interval: profit_interval} = args) do
    symbol = String.upcase(symbol)
    Logger.info("Initializing new trader for #{symbol}")

    with tick_size <- fetch_tick_size(symbol) do
      {:ok,
       %State{
         symbol: symbol,
         profit_interval: profit_interval,
         tick_size: tick_size
       }}
    end
  end

  defp fetch_tick_size(symbol) do
    Binance.get_exchange_info()
    |> elem(1)
    |> Map.get(:symbols)
    |> Enum.find(&(&1["symbol"] == symbol))
    |> Map.get("filters")
    |> Enum.find(&(&1["filterType"] == "PRICE_FILTER"))
    |> Map.get("tickSize")
  end
end
