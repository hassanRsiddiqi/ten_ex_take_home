defmodule TenExTakeHome.Test.Support.Mocks.Marvel do
  use ExUnit.CaseTemplate
  import Mox

  @spec expect_marvel_called(:success, integer) :: {:ok, %{}}
  def expect_marvel_called(:success, n) do
    expect(MarvelMock, :get_characters, n, fn ->
      {:ok, success_data()}
    end)
  end

  @spec expect_marvel_called(:success) :: {:ok, %{}}
  def expect_marvel_called(:success) do
    expect(MarvelMock, :get_characters, fn ->
      {:ok, success_data()}
    end)
  end

  @spec expect_marvel_called(:no_api_key) :: {:error, :unsatisfied_authentication}
  def expect_marvel_called(:no_api_key) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 409,
         body: %{"code" => "MissingParameter", "message" => "You must provide a user key."}
       }}
    end)
  end

  @spec expect_marvel_called(:no_hash_given) :: {:error, :unsatisfied_authentication}
  def expect_marvel_called(:no_hash_given) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 409,
         body: %{"code" => "MissingParameter", "message" => "You must provide a hash."}
       }}
    end)
  end

  @spec expect_marvel_called(:invalid_data_limit) :: {:error, :unsatisfied_authentication}
  def expect_marvel_called(:invalid_data_limit) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 409,
         body: %{"code" => "409", "status" => "You may not request more than 100 items."}
       }}
    end)
  end

  @spec expect_marvel_called(:unsatisfied_authentication) :: {:error, :unsatisfied_authentication}
  def expect_marvel_called(:unsatisfied_authentication) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 409,
         body: %{"code" => "MissingParams", "message" => "Missing parameters"}
       }}
    end)
  end

  @spec expect_marvel_called(:invalid_api_key) :: {:error, :authorization_error}
  def expect_marvel_called(:invalid_api_key) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 401,
         body: %{"code" => "InvalidCredentials", "message" => "The passed API key is invalid."}
       }}
    end)
  end

  @spec expect_marvel_called(:invalid_hash_given) :: {:error, :authorization_error}
  def expect_marvel_called(:invalid_hash_given) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 401,
         body: %{"code" => "InvalidCredentials", "message" => "The passed API key is invalid."}
       }}
    end)
  end

  @spec expect_marvel_called(:authorization_error) :: {:error, :authorization_error}
  def expect_marvel_called(:authorization_error) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 401,
         body: %{"code" => "InvalidCredentials", "message" => "The passed API key is invalid."}
       }}
    end)
  end

  @spec expect_marvel_called(:invalid_base_url) :: {:error, :internal_server_error}
  def expect_marvel_called(:invalid_base_url) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 404,
         body: %{
           "code" => "ResourceNotFound",
           "message" =>
             "/v1/public/characters123?ts=TS_HERE&apikey=KEY_HERE&hash=HASH_HERE&limit=1 does not exist"
         }
       }}
    end)
  end

  @spec expect_marvel_called(:limit_surpassed) :: {:error, :limit_surpassed}
  def expect_marvel_called(:limit_surpassed) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 429,
         body: %{"code" => "LimitSurpassed", "message" => "Daily limit exceeds."}
       }}
    end)
  end

  @spec expect_marvel_called(:forbidden) :: {:error, :forbidden}
  def expect_marvel_called(:forbidden) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 403,
         body: %{"code" => "forbidden", "message" => "You are not allowed to access this page"}
       }}
    end)
  end

  @spec expect_marvel_called(:timeout) :: {:error, :timeout}
  def expect_marvel_called(:timeout) do
    expect(MarvelTeslaMock, :call, fn %{method: :get}, _opts ->
      {:error, :timeout}
    end)
  end

  @spec expect_marvel_called(:authorization_error, integer) :: {:error, :authorization_error}
  def expect_marvel_called_outside(:authorization_error, n \\ 1) do
    expect(MarvelMock, :get_characters, n, fn ->
      {:error, :authorization_error}
    end)
  end

  defp success_data() do
    %{
      "count" => 1,
      "limit" => 1,
      "offset" => 0,
      "results" => [
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
      ],
      "total" => 1562
    }
  end
end
