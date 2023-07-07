defmodule TenExTakeHomeWeb.DataLiveTest do
  use TenExTakeHomeWeb.ConnCase

  import Mox

  setup :verify_on_exit!

  alias TenExTakeHome.External.Marvel
  import TenExTakeHome.Test.Support.Mocks.Marvel

  describe "display characters" do
    test "displays the correct template and data", %{conn: conn} do
      expect_marvel_called(:success, 2)

      conn = get(conn, "/data")
      assert html_response(conn, 200) =~ "<h2>Characters Table</h2>"

      {:ok, view, html} = live(conn)
      assert html =~ "Characters Table"
      assert html =~ "<th>Name</th>"
      assert html =~ "<th>Id</th>"
      assert html =~ "<th>Resource URI</th>"
      assert html =~ "<td>1011334</td>"
      assert html =~ "<td>3-D Man</td>"
      assert html =~ "<td>http://gateway.marvel.com/v1/public/characters/1011334</td>"
    end

    test "when API return error It should blank table", %{conn: conn} do
      expect_marvel_called_outside(:authorization_error, 2)

      conn = get(conn, "/data")
      {:ok, view, html} = live(conn)

      assert html =~ "Characters Table"
      assert html =~ "<th>Id</th>"
      assert html =~ "<th>Name</th>"
      assert html =~ "<th>Resource URI</th>"

      refute html =~ "<td>1011334</td>"
      refute html =~ "<td>3-D Man</td>"
      refute html =~ "<td>http://gateway.marvel.com/v1/public/characters/1011334</td>"
    end
  end
end
