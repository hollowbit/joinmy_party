defmodule JoinmyPartyWeb.PageControllerTest do
  use JoinmyPartyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "JoinMy.Party"
  end
end
