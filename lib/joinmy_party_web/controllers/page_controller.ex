defmodule JoinmyPartyWeb.PageController do
  use JoinmyPartyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
