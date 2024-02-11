defmodule UrfuApi.Istudent.Auth do
  @moduledoc false
  alias UrfuApi.AuthHelpers
  alias UrfuApi.Istudent
  alias UrfuApi.Istudent.Auth.Token

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def sign_in(username, password) do
    case get_auth_tokens(username, password) do
      {:ok, auth_tokens} ->
        token =
          auth_tokens
          |> get_auth_url()
          |> get_access_token(username)

        {:ok, token}

      err ->
        err
    end
  end

  defp get_auth_tokens(username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    response = Istudent.Client.request_urfu_sso!(:post, body, [])

    case AuthHelpers.ensure_redirect(response) do
      :error -> {:error, "Wrong credentials"}
      {:ok, response} -> {:ok, AuthHelpers.fetch_cookies!(response)}
    end
  end

  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    response = Istudent.Client.request_urfu_sso!(:get, [], [{"cookie", cookies}])

    AuthHelpers.fetch_location!(response)
  end

  defp get_access_token(url, username) do
    url
    |> Istudent.Client.request_istudent_token!()
    |> AuthHelpers.fetch_cookie!()
    |> Token.new(username)
  end
end
