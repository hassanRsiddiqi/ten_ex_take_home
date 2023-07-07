defmodule TenExTakeHome.MarvelTest do
  use TenExTakeHome.DataCase

  import Mox
  import TenExTakeHome.Test.Support.Mocks.Marvel

  alias TenExTakeHome.External.Marvel

  setup :verify_on_exit!

  setup do
    stub_with(MarvelMock, TenExTakeHome.External.Marvel.HTTP)
    :ok
  end

  describe "get characters" do
    test "successful response from API" do
      expect_marvel_called(:success)
      assert {:ok, data} = Marvel.get_characters()

      assert data["count"] == 1
      assert data["limit"] == 1
      assert data["offset"] == 0
      assert data["total"] == 1562
      assert data["results"] == result_response()
    end

    test "error when no credentials are provided" do
      expect_marvel_called(:authorization_error)
      assert {:error, :authorization_error} = Marvel.get_characters()
    end

    test "error when invalid base url" do
      expect_marvel_called(:invalid_base_url)
      assert {:error, :internal_server_error} = Marvel.get_characters()
    end

    test "error when there is no api key given" do
      expect_marvel_called(:no_api_key)
      assert {:error, :unsatisfied_authentication} = Marvel.get_characters()
    end

    test "error when invalid api key given" do
      expect_marvel_called(:invalid_api_key)
      assert {:error, :authorization_error} = Marvel.get_characters()
    end

    test "error when no hash given" do
      expect_marvel_called(:no_hash_given)
      assert {:error, :unsatisfied_authentication} = Marvel.get_characters()
    end

    test "error when invalid hash given" do
      expect_marvel_called(:invalid_hash_given)
      assert {:error, :authorization_error} = Marvel.get_characters()
    end

    test "error when daily or hourly limit got exceed" do
      expect_marvel_called(:limit_surpassed)
      assert {:error, :limit_surpassed} = Marvel.get_characters()
    end

    test "error when invalid inputs params" do
      expect_marvel_called(:unsatisfied_authentication)
      assert {:error, :unsatisfied_authentication} = Marvel.get_characters()
    end

    test "error when access to restricted page" do
      expect_marvel_called(:forbidden)
      assert {:error, :forbidden} = Marvel.get_characters()
    end

    test "error when timeout" do
      expect_marvel_called(:timeout)
      assert {:error, :internal_server_error} = Marvel.get_characters()
    end

    test "error when pagination limit and offset exceeds" do
      expect_marvel_called(:invalid_data_limit)
      assert {:error, :invalid_data_limit} = Marvel.get_characters()
    end
  end

  defp result_response() do
    [
      %{
        "comics" => %{
          "available" => 12,
          "collectionURI" => "http://gateway.marvel.com/v1/public/characters/1011334/comics",
          "items" => [
            %{
              "name" => "Avengers: The Initiative (2007) #14",
              "resourceURI" => "http://gateway.marvel.com/v1/public/comics/21366"
            },
            %{
              "name" => "Marvel Premiere (1972) #35",
              "resourceURI" => "http://gateway.marvel.com/v1/public/comics/10223"
            }
          ],
          "returned" => 2
        },
        "description" => "",
        "events" => %{
          "available" => 1,
          "collectionURI" => "http://gateway.marvel.com/v1/public/characters/1011334/events",
          "items" => [
            %{
              "name" => "Secret Invasion",
              "resourceURI" => "http://gateway.marvel.com/v1/public/events/269"
            }
          ],
          "returned" => 1
        },
        "id" => 1_011_334,
        "modified" => "2014-04-29T14:18:17-0400",
        "name" => "3-D Man",
        "resourceURI" => "http://gateway.marvel.com/v1/public/characters/1011334",
        "series" => %{
          "available" => 3,
          "collectionURI" => "http://gateway.marvel.com/v1/public/characters/1011334/series",
          "items" => [
            %{
              "name" => "Avengers: The Initiative (2007 - 2010)",
              "resourceURI" => "http://gateway.marvel.com/v1/public/series/1945"
            },
            %{
              "name" => "Deadpool (1997 - 2002)",
              "resourceURI" => "http://gateway.marvel.com/v1/public/series/2005"
            },
            %{
              "name" => "Marvel Premiere (1972 - 1981)",
              "resourceURI" => "http://gateway.marvel.com/v1/public/series/2045"
            }
          ],
          "returned" => 3
        },
        "stories" => %{
          "available" => 2,
          "collectionURI" => "http://gateway.marvel.com/v1/public/characters/1011334/stories",
          "items" => [
            %{
              "name" => "Cover #19947",
              "resourceURI" => "http://gateway.marvel.com/v1/public/stories/19947",
              "type" => "cover"
            },
            %{
              "name" => "The 3-D Man!",
              "resourceURI" => "http://gateway.marvel.com/v1/public/stories/19948",
              "type" => "interiorStory"
            }
          ],
          "returned" => 20
        },
        "thumbnail" => %{
          "extension" => "jpg",
          "path" => "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784"
        },
        "urls" => [
          %{
            "type" => "detail",
            "url" =>
              "http://marvel.com/characters/74/3-d_man?utm_campaign=apiRef&utm_source=e9b8ba27c3f3a84c3cb4b4b9ea48a3b1"
          },
          %{
            "type" => "wiki",
            "url" =>
              "http://marvel.com/universe/3-D_Man_(Chandler)?utm_campaign=apiRef&utm_source=e9b8ba27c3f3a84c3cb4b4b9ea48a3b1"
          },
          %{
            "type" => "comiclink",
            "url" =>
              "http://marvel.com/comics/characters/1011334/3-d_man?utm_campaign=apiRef&utm_source=e9b8ba27c3f3a84c3cb4b4b9ea48a3b1"
          }
        ]
      }
    ]
  end
end
