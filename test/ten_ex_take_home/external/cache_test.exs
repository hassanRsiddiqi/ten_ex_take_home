defmodule TenExTakeHome.External.Marvel.CacheTest do
  use TenExTakeHome.DataCase
  use ExUnit.Case

  import Mox
  import TenExTakeHome.Test.Support.Mocks.Marvel
  import ExUnit.CaptureLog

  alias TenExTakeHome.External.Marvel.Cache
  alias TenExTakeHome.Repo
  alias TenExTakeHome.Stats.Stat

  setup :verify_on_exit!
  setup :set_mox_from_context

  setup do
    stub_with(MarvelMock, TenExTakeHome.External.Marvel.HTTP)
    :ok
  end

  @default_params %{limit: 1, offset: 0}

  describe "get_character/0" do
    test "get data from cache" do
      # given
      pid = setup_cache_server()
      expect_marvel_called(:success)

      # when
      assert {:ok, characters} = Cache.get_characters(@default_params, pid)

      # then
      assert characters["count"] == 1
      assert characters["limit"] == 1
      assert characters["offset"] == 0
      assert characters["total"] == 1562
    end

    test "Lets not call the API when data is already in the cache" do
      # given
      pid = setup_cache_server()
      expect_marvel_called(:success)

      # pre process
      assert {:ok, _characters} = Cache.get_characters(@default_params, pid)

      # fetch from cache, without mox
      assert {:ok, _characters} = Cache.get_characters(@default_params, pid)
    end

    test "Retry when API returns error" do
      # setup
      pid = setup_cache_server()

      # first attempt return error
      # when
      expect_marvel_called(:authorization_error)

      # then
      assert capture_log(fn ->
               assert {:error, :authorization_error} = Cache.get_characters(@default_params, pid)
             end) =~ "InvalidCredentials: The passed API key is invalid"

      # successful attempt
      # when
      expect_marvel_called(:success)

      # then
      assert {:ok, _characters} = Cache.get_characters(@default_params, pid)
    end
  end

  describe "Stats" do
    test "create stats when api got called" do
      # given
      pid = setup_cache_server()
      expect_marvel_called(:success)

      # when
      assert {:ok, _characters} = Cache.get_characters(@default_params, pid)
      stats = Repo.get_by(Stat, status: "success")

      assert stats.status == :success
      assert not is_nil(stats.inserted_at)
      assert not is_nil(stats.updated_at)
    end

    test "should't create stats when data is already cached" do
      # given
      pid = setup_cache_server()

      # when
      expect_marvel_called(:success)
      assert {:ok, _characters} = Cache.get_characters(@default_params, pid)
      assert Repo.aggregate(Stat, :count) == 1

      # fetch again from cache
      assert {:ok, _characters} = Cache.get_characters(@default_params, pid)
      assert Repo.aggregate(Stat, :count) == 1
    end

    test "create entry in db when API returns error" do
      # given
      pid = setup_cache_server()
      expect_marvel_called(:invalid_data_limit)

      # when
      assert {:error, :invalid_data_limit} = Cache.get_characters(@default_params, pid)
      stats = Repo.get_by(Stat, status: "error")

      # then
      assert stats.status == :error
      assert not is_nil(stats.inserted_at)
      assert not is_nil(stats.updated_at)
    end
  end

  describe "Verify state" do
    test "default inital state" do
      # given
      pid = setup_cache_server()

      # then
      state = Cache.state(pid)
      assert state == %{characters: %{}}
    end

    test "must store successful call" do
      # given
      pid = setup_cache_server()

      # when
      expect_marvel_called(:success)
      {:ok, _characters} = Cache.get_characters(@default_params, pid)

      %{characters: [character]} = Cache.state(pid)

      # then
      assert character["count"] == 1
      assert character["limit"] == 1
      assert character["offset"] == 0
      assert character["total"] == 1562
    end

    test "lets not store duplicate entries" do
      # given
      pid = setup_cache_server()

      # when
      expect_marvel_called(:success)
      {:ok, _characters} = Cache.get_characters(@default_params, pid)
      {:ok, _characters} = Cache.get_characters(@default_params, pid)

      %{characters: character} = Cache.state(pid)
      assert Enum.count(character) == 1
    end

    test "must accept entries in storage" do
      # given
      pid = setup_cache_server()
      params = %{limit: 1, offset: 1}

      # when
      expect_marvel_called(:success)
      expect_marvel_called(:pagination, params)
      {:ok, _characters} = Cache.get_characters(@default_params, pid)
      {:ok, _characters} = Cache.get_characters(params, pid)

      %{characters: character} = Cache.state(pid)
      assert Enum.count(character) == 2
    end

    test "ignore errors" do
      # given
      pid = setup_cache_server()

      # when
      expect_marvel_called(:invalid_data_limit)
      {:error, :invalid_data_limit} = Cache.get_characters(@default_params, pid)

      %{characters: character} = Cache.state(pid)
      assert Enum.count(character) == 0
    end
  end

  defp setup_cache_server() do
    {:ok, pid} = GenServer.start_link(TenExTakeHome.External.Marvel.Cache, _init_args = nil)
    pid
  end
end
