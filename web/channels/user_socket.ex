defmodule Discuss.UserSocket do
  use Phoenix.Socket

  channel "comments:*", Discuss.CommentsChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(%{"token" => user_token}, socket) do
    case Phoenix.Token.verify(socket, "key", user_token) do
      {:ok, user_id} ->
        IO.inspect user_id
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} ->
        :error
    end
  end

  def id(_socket), do: nil
end
