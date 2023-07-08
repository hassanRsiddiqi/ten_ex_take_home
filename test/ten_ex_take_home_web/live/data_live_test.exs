defmodule TenExTakeHomeWeb.DataLiveTest do
  use TenExTakeHomeWeb.ConnCase

  import Mox

  setup :verify_on_exit!
  setup :set_mox_from_context

  import TenExTakeHome.Test.Support.Mocks.Marvel

  describe "display characters" do
    test "displays the correct template and data", %{conn: conn} do
      expect_marvel_called(:success, 2)

      conn = get(conn, "/data")
      assert html_response(conn, 200) =~ "<h2>Characters Table</h2>"

      {:ok, _view, html} = live(conn)
      assert html =~ "Characters Table"
      assert html =~ "<th>Name</th>"
      assert html =~ "<th>Id</th>"
      assert html =~ "<th>Resource URI</th>"
      assert html =~ "<td>1011334</td>"
      assert html =~ "<td>3-D Man</td>"
      assert html =~ "<td>http://gateway.marvel.com/v1/public/characters/1011334</td>"
    end
  end
end
