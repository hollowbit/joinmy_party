defmodule JoinmyPartyWeb.PdilemmaLiveTest do
  use JoinmyPartyWeb.ConnCase

  import Phoenix.LiveViewTest
  import JoinmyParty.PrisonersDilemmaFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_pdilemma(_) do
    pdilemma = pdilemma_fixture()
    %{pdilemma: pdilemma}
  end

  describe "Index" do
    setup [:create_pdilemma]

    test "lists all pdilemmas", %{conn: conn, pdilemma: pdilemma} do
      {:ok, _index_live, html} = live(conn, Routes.pdilemma_index_path(conn, :index))

      assert html =~ "Listing Pdilemmas"
      assert html =~ pdilemma.name
    end

    test "saves new pdilemma", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.pdilemma_index_path(conn, :index))

      assert index_live |> element("a", "New Pdilemma") |> render_click() =~
               "New Pdilemma"

      assert_patch(index_live, Routes.pdilemma_index_path(conn, :new))

      assert index_live
             |> form("#pdilemma-form", pdilemma: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#pdilemma-form", pdilemma: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.pdilemma_index_path(conn, :index))

      assert html =~ "Pdilemma created successfully"
      assert html =~ "some name"
    end

    test "updates pdilemma in listing", %{conn: conn, pdilemma: pdilemma} do
      {:ok, index_live, _html} = live(conn, Routes.pdilemma_index_path(conn, :index))

      assert index_live |> element("#pdilemma-#{pdilemma.id} a", "Edit") |> render_click() =~
               "Edit Pdilemma"

      assert_patch(index_live, Routes.pdilemma_index_path(conn, :edit, pdilemma))

      assert index_live
             |> form("#pdilemma-form", pdilemma: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#pdilemma-form", pdilemma: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.pdilemma_index_path(conn, :index))

      assert html =~ "Pdilemma updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes pdilemma in listing", %{conn: conn, pdilemma: pdilemma} do
      {:ok, index_live, _html} = live(conn, Routes.pdilemma_index_path(conn, :index))

      assert index_live |> element("#pdilemma-#{pdilemma.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#pdilemma-#{pdilemma.id}")
    end
  end

  describe "Show" do
    setup [:create_pdilemma]

    test "displays pdilemma", %{conn: conn, pdilemma: pdilemma} do
      {:ok, _show_live, html} = live(conn, Routes.pdilemma_show_path(conn, :show, pdilemma))

      assert html =~ "Show Pdilemma"
      assert html =~ pdilemma.name
    end

    test "updates pdilemma within modal", %{conn: conn, pdilemma: pdilemma} do
      {:ok, show_live, _html} = live(conn, Routes.pdilemma_show_path(conn, :show, pdilemma))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Pdilemma"

      assert_patch(show_live, Routes.pdilemma_show_path(conn, :edit, pdilemma))

      assert show_live
             |> form("#pdilemma-form", pdilemma: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#pdilemma-form", pdilemma: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.pdilemma_show_path(conn, :show, pdilemma))

      assert html =~ "Pdilemma updated successfully"
      assert html =~ "some updated name"
    end
  end
end
