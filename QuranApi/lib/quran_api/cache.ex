defmodule QuranApi.Cache do
  @moduledoc """
  Simple ETS-based caching module for frequently accessed data.
  """

  use GenServer

  @table_name :quran_api_cache
  @daily_verse_key :daily_verse
  @metadata_key :metadata
  @stats_key :stats

  # Client API

  @doc """
  Starts the cache GenServer.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Gets a value from the cache.
  Returns `{:ok, value}` if found, `:miss` if not found or expired.
  """
  @spec get(atom()) :: {:ok, any()} | :miss
  def get(key) do
    case :ets.lookup(@table_name, key) do
      [{^key, value, expires_at}] ->
        if DateTime.compare(DateTime.utc_now(), expires_at) == :lt do
          {:ok, value}
        else
          :ets.delete(@table_name, key)
          :miss
        end

      [] ->
        :miss
    end
  end

  @doc """
  Puts a value in the cache with a TTL in seconds.
  """
  @spec put(atom(), any(), integer()) :: :ok
  def put(key, value, ttl_seconds) do
    expires_at = DateTime.add(DateTime.utc_now(), ttl_seconds, :second)
    :ets.insert(@table_name, {key, value, expires_at})
    :ok
  end

  @doc """
  Deletes a key from the cache.
  """
  @spec delete(atom()) :: :ok
  def delete(key) do
    :ets.delete(@table_name, key)
    :ok
  end

  @doc """
  Gets or computes a value.
  If the key exists and is not expired, returns the cached value.
  Otherwise, calls the function, caches the result, and returns it.
  """
  @spec get_or_compute(atom(), integer(), (-> any())) :: any()
  def get_or_compute(key, ttl_seconds, fun) do
    case get(key) do
      {:ok, value} ->
        value

      :miss ->
        value = fun.()
        put(key, value, ttl_seconds)
        value
    end
  end

  # Cache keys
  def daily_verse_key, do: @daily_verse_key
  def metadata_key, do: @metadata_key
  def stats_key, do: @stats_key

  # Server Callbacks

  @impl true
  def init(_opts) do
    :ets.new(@table_name, [:named_table, :set, :public, read_concurrency: true])
    {:ok, %{}}
  end
end
