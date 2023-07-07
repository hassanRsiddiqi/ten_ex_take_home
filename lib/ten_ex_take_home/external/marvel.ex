defmodule TenExTakeHome.External.Marvel do
  @moduledoc """
  Behaviour for Marvel client. This module should be used as API for Marvel client.
  """

  @type marvel_error ::
          :authorization_error
          | :limit_surpassed
          | :unsatisfied_authentication
          | :forbidden
          | :internal_server_error
          | :invalid_data_limit
          | any()

  @type marvel_result :: %{
          offset: integer,
          limit: integer,
          total: integer,
          count: integer,
          results: [map()]
        }

  @doc """
  List the characters from Marvel API
  """
  @callback get_characters() ::
              {:ok, marvel_result()} | {:error, marvel_error()}

  @doc """
  Performs characters search against Marvel API.
  """
  def get_characters(), do: client_module().get_characters()

  # private methods
  defp client_module(), do: Application.get_env(:ten_ex_take_home, :marvel_client_module)
end
