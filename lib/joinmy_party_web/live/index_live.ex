defmodule JoinmyPartyWeb.IndexWebLive do
  alias JoinmyPartyWeb.PdilemmaWebRules
  use JoinmyPartyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="font-bold sm:text-6xl text-4xl text-slate-800 text-center">JoinMy.Party 🎉</h1>
      <h2 class="uppercase italic text-xl text-slate-500 text-center">Play interactive games with friends online or in-person <span class="not-italic">📱</span></h2>

      <.form for={@room_form} phx-change="set_room_name" phx-submit="join_room" class="my-8 max-w-3xl mx-auto flex flex-col items-center">
        <div class="flex flex-row w-full flex-wrap sm:flex-nowrap">
          <.input type="text" class="w-full my-4 p-2 rounded-lg border-2 border-slate-200 flex-grow" placeholder="Enter a room name" field={@room_form["room_name"]} />
          <button class={"sm:w-44 w-full sm:m-4 p-4 mx-auto rounded-md text-slate-50 font-bold " <> (if @room_form.params["room_name"] == "", do: "bg-slate-500 cursor-default", else: if @room_exists, do: "bg-indigo-500 hover:bg-indigo-700", else: "bg-emerald-500 hover:bg-emerald-700")} type="submit">
            <%= if @room_exists, do: "Join Game", else: "Start Game" %>
          </button>
        </div>
        <%= if @room_exists do %>
          <small class="text-slate-500 text-sm italic text-center">This party was already created. Click to join!</small>
        <% end %>
      </.form>

      <JoinmyPartyWeb.PdilemmaWebRules.modal />
      <p class="text-center">Currently, the only game available is Prisoner's Dilemma. <a class="cursor-pointer" onclick={JoinmyPartyWeb.PdilemmaWebRules.onclick}>Rules 🛈</a></p>
    </div>
    """
  end

  # Render Helpers
  def input(assigns) do
    ~H"""
    <input type="text" name={@field.name} id={@field.id} value={@field.value} class={@class} placeholder={@placeholder} />
    """
  end

  # Livecycle Functions
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Home", room_form: to_form(%{"room_name" => ""}), room_exists: false)}
  end

  # Event Handlers
  def handle_event("set_room_name", %{"room_name" => room_name}, socket) do
    room_exists = room_exists(room_name)
    form = %{ "room_name" => room_name } |> to_form
    {:noreply, assign(socket, room_form: form, room_exists: room_exists)}
  end

  def handle_event("join_room", %{"room_name" => room_name}, socket) do
    {:noreply, push_navigate(socket, to: "/#{room_name}")}
  end

  def room_exists(room_name) do
    case :global.whereis_name("party:" <> String.downcase(room_name)) do
      :undefined -> false
      _ -> true
    end
  end


end
