defmodule UrFUAPI.UBU.Auth do
  @moduledoc false
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.UBU
  alias UrFUAPI.UBU.Auth.Token

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def sign_in(username, password) do
    case get_auth_tokens(username, password) do
      {:ok, auth_tokens} ->
        token =
          auth_tokens
          |> get_auth_url()
          |> get_ubu_login_code()
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

    with {:ok, response} <- UBU.Client.request_urfu_sso(:post, body, []) do
      case AuthHelpers.ensure_redirect(response) do
        :error -> {:error, "Wrong credentials"}
        {:ok, response} -> {:ok, AuthHelpers.fetch_cookies!(response)}
      end
    end
  end

  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    with {:ok, response} <- UBU.Client.request_urfu_sso(:get, [], [{"cookie", cookies}]) do
      AuthHelpers.fetch_location!(response)
    end
  end

  defp get_ubu_login_code(url) do
    with {:ok, response} <- UBU.Client.request_ubu_code(url) do
      parse_ubu_code(response)
    end
  end

  defp parse_ubu_code(response) do
    %{query: query} =
      response
      |> AuthHelpers.fetch_location!()
      |> URI.parse()

    query
    |> URI.query_decoder()
    |> Map.new()
    |> Map.fetch!("code")
  end

  defp get_access_token(login_code, username) do
    body = %{
      method: "User.Login",
      params: %{
        code: login_code
      }
    }

    with {:ok, response} <- UBU.Client.request_ubu_token(body) do
      response
      |> AuthHelpers.fetch_cookies!()
      |> Token.new(username)
    end
  end
end
