defmodule Discuss.TopicController do
  use Discuss.Web, :controller
  alias Discuss.Topic

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete] 
  plug :check_topic_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    render conn, "index.html", topics: Repo.all(Topic)
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"topic" => topic}) do
    changeset = conn.assigns.user
    |> build_assoc(:topics)
    |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn 
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} -> 
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)
    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => new_topic}) do
    topic = Repo.get(Topic, topic_id)
    changeset = topic |> Topic.changeset(new_topic)
    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn 
        |> put_flash(:info, "Successfully updated!")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: topic
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get(Topic, topic_id) |> Repo.delete!
    
    conn
    |> put_flash(:info, "Topic deleted!")
    |> redirect(to: topic_path(conn, :index))
  end

  defp check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn
    topic = Discuss.Repo.get(Topic, topic_id)
    
    cond do
      conn.assigns.user.id == topic.user_id ->
        conn
      true ->
        conn
        |> put_flash(:error, "Action not allowed")
        |> redirect(to: topic_path(conn, :index))
        |> halt()
    end
  end  
end