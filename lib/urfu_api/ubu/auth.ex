defmodule UrfuApi.Ubu.Auth do
  @moduledoc false
  alias UrfuApi.AuthHelpers
  alias UrfuApi.Ubu
  alias UrfuApi.Ubu.Auth.Token

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

    response = Ubu.Client.request_urfu_sso!(:post, body, [])

    case AuthHelpers.ensure_redirect(response) do
      :error -> {:error, "Wrong credentials"}
      {:ok, response} -> {:ok, AuthHelpers.fetch_cookies!(response)}
    end
  end

  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    response = Ubu.Client.request_urfu_sso!(:get, [], [{"cookie", cookies}])

    AuthHelpers.fetch_location!(response)
  end

  defp get_ubu_login_code(url) do
    url
    |> Ubu.Client.request_ubu_code!()
    |> parse_ubu_code()
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

    body
    |> Ubu.Client.request_ubu_token!()
    |> AuthHelpers.fetch_cookies!()
    |> Token.new(username)
  end
end
