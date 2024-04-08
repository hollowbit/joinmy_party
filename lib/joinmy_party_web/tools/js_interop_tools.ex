defmodule JoinmyPartyWeb.Tools.JsInteropTools do
  @moduledoc """
  Tools for working with JS interop
  """


  def push_js(socket, to, js) do
    event_details = %{
      to: to,
      encodedJS: Phoenix.json_library().encode!(js.ops)
    }

    socket
    |> Phoenix.LiveView.push_event("exec-js", event_details);
  end

end
