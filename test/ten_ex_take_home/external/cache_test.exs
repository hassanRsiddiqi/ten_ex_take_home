defmodule TenExTakeHome.External.Marvel.CacheTest do
  use TenExTakeHome.DataCase
  use ExUnit.Case

  import Mox
  import TenExTakeHome.Test.Support.Mocks.Marvel
  import ExUnit.CaptureLog

  alias TenExTakeHome.External.Marvel.Cache

  setup :verify_on_exit!
  setup :set_mox_from_context

  setup do
    stub_with(MarvelMock, TenExTakeHome.External.Marvel.HTTP)
    :ok
  end

  describe "get_character/0" do
    test "get data from cache" do
      # given
      pid = setup_cache_server()
      expect_marvel_called(:success)

      # when
      assert {:ok, characters} = Cache.get_characters(pid)

      # then
      assert characters["count"] == 1
      assert characters["limit"] == 1
      assert characters["offset"] == 0
      assert characters["total"] == 1562
    end

    test "Lets not call the API when data is already in the cache" do
      #given
      pid = setup_cache_server()
      expect_marvel_called(:success)

      # pre process
      assert {:ok, _characters} = Cache.get_characters(pid)

      # fetch from cache, without mox
      assert {:ok, _characters} = Cache.get_characters(pid)
    end

    test "Retry when API returns error" do
      # setup
      pid = setup_cache_server()

      # first attempt return error
      # when
      expect_marvel_called(:authorization_error)

      # then
      assert capture_log(fn ->
        assert  {:error, :authorization_error} = Cache.get_characters(pid)
      end) =~ "InvalidCredentials: The passed API key is invalid"


      # successful attempt
      # when
      expect_marvel_called(:success)

      # then
      assert {:ok, _characters} = Cache.get_characters(pid)
    end
  end


  defp setup_cache_server() do
    {:ok, pid} = GenServer.start_link(TenExTakeHome.External.Marvel.Cache, _init_args = nil)
    pid
  end
end
