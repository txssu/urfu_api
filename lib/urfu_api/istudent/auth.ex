defmodule UrFUAPI.IStudent.Auth do
  @moduledoc false
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.IStudent
  alias UrFUAPI.IStudent.Auth.Token

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

    with {:ok, response} <- IStudent.Client.request_urfu_sso(:post, body, []) do
      case AuthHelpers.ensure_redirect(response) do
        :error -> {:error, "Wrong credentials"}
        {:ok, response} -> {:ok, AuthHelpers.fetch_cookies!(response)}
      end
    end
  end

  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    with {:ok, response} <- IStudent.Client.request_urfu_sso(:get, [], [{"cookie", cookies}]) do
      AuthHelpers.fetch_location!(response)
    end
  end

  defp get_access_token(url, username) do
    with {:ok, response_with_token} <- IStudent.Client.request_istudent_token(url) do
      response_with_token
      |> AuthHelpers.fetch_cookie!()
      |> Token.new(username)
    end
  end
end
