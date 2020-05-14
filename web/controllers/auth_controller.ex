defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth
  
  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
    changeset = User.changeset(%User{}, user_params)

    sign_in(conn, changeset)
  end


  def sign_out(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: topic_path(conn, :index))
  end

  defp sign_in(conn, changeset) do
    case update_or_insert_user(changeset) do
      {:ok, user } ->
        conn
        |> put_flash(:info, "Welcome back")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason } ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp update_or_insert_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end
end