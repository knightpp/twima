defmodule Twima.Memcache do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @spec put(String.t(), term(), pos_integer()) :: :ok
  def put(key, value, timeout \\ 90_000) do
    GenServer.call(__MODULE__, {:put, key, value, timeout})
  end

  @spec pop(String.t()) :: {:ok, term()} | :error
  def pop(key) do
    GenServer.call(__MODULE__, {:pop, key})
  end

  @impl true
  def init(_arg) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:put, key, value, timeout}, _from, map) do
    Process.send_after(self(), {:expired, key}, timeout)

    {:reply, :ok, Map.put(map, key, value)}
  end

  @impl true
  def handle_call({:pop, key}, _from, map) do
    case {Map.get(map, key, :error), map} do
      {:error, map} -> {:reply, :error, map}
      {resp, map} -> {:reply, {:ok, resp}, map}
    end
  end

  @impl true
  def handle_info({:expired, key}, map) do
    {:noreply, Map.delete(map, key)}
  end
end
