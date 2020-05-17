defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel
  alias Discuss.{Topic, Comment}

  def join("comments:" <> topic_id, _params, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Topic
      |> Repo.get(topic_id)
      |> Repo.preload(comments: [:user])

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in("comment:add", %{"content" => comment_text}, socket) do
    topic = socket.assigns.topic

    changeset = topic
    |> build_assoc(:comments, user_id: socket.assigns.user_id)
    |> Comment.changeset(%{text: comment_text})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast!(socket, "comments:#{topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  def handle_in(name, _message, socket) do
    {:reply, :ok, socket}
  end
end
