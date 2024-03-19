defmodule UrFUAPI.UBU.Auth do
  @moduledoc false
  use Publicist

  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.UBU
  alias UrFUAPI.UBU.Auth.Token
  alias UrfuApi.Utils

  require Logger

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def sign_in(username, password) do
    with {:ok, auth_tokens} <- get_auth_tokens(username, password),
         {:ok, auth_url} <- get_auth_url(auth_tokens),
         {:ok, login_code} <- get_ubu_login_code(auth_url) do
      get_access_token(login_code, username)
    end
  end

  defp get_auth_tokens(username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    with {:ok, response} <- UBU.Client.request_urfu_sso(:post, body, []),
         {:ok, response_good_credentials} <- ensure_auth_ok(response) do
      fetch_auth_cookies(response_good_credentials)
    end
  end

  defp ensure_auth_ok(response) do
    case AuthHelpers.ensure_redirect(response) do
      {:ok, _response} = ok -> ok
      :error -> {:error, :wrong_credentials}
    end
  end

  defp fetch_auth_cookies(response) do
    case AuthHelpers.fetch_cookies(response) do
      [_c1, _c2] = cookies ->
        {:ok, cookies}

      _cookies ->
        "request_urfu_sso(:post, ...)"
        |> format_error(response)
        |> Logger.error()

        {:error, :invalid_server_response}
    end
  end

  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    with {:ok, response} <- UBU.Client.request_urfu_sso(:get, [], [{"cookie", cookies}]) do
      case AuthHelpers.fetch_location(response) do
        {:ok, _location} = ok ->
          ok

        :error ->
          "request_urfu_sso(:get, ...)"
          |> format_error(response)
          |> Logger.error()

          {:error, :invalid_server_response}
      end
    end
  end

  defp get_ubu_login_code(url) do
    with {:ok, response} <- UBU.Client.request_ubu_code(url) do
      parse_ubu_code(response)
    end
  end

  defp parse_ubu_code(response) do
    with {:ok, query_stream} <- fetch_location_query(response) do
      maybe_code = Enum.find_value(query_stream, &if(elem(&1, 0) == "code", do: elem(&1, 1)))

      case maybe_code do
        nil ->
          Logger.error("UBU returns location without code.")

          {:error, :invalid_server_response}

        code ->
          {:ok, code}
      end
    end
  end

  defp fetch_location_query(response) do
    case AuthHelpers.fetch_location(response) do
      {:ok, location} ->
        %{query: query} = URI.parse(location)
        {:ok, URI.query_decoder(query)}

      :error ->
        "request_ubu_code(...)"
        |> format_error(response)
        |> Logger.error()

        {:error, :invalid_server_response}
    end
  end

  defp get_access_token(login_code, username) do
    body = %{
      method: "User.Login",
      params: %{
        code: login_code
      }
    }

    with {:ok, response} <- UBU.Client.request_ubu_token(body) do
      case AuthHelpers.fetch_cookies(response) do
        [_c1, _c2] = cookies ->
          {:ok, Token.new(cookies, username)}

        _cookies ->
          "request_ubu_token(...)"
          |> format_error(response)
          |> Logger.error()

          {:error, :invalid_server_response}
      end
    end
  end

  defp format_error(method, response), do: Utils.invalid_response_format_error("UBU.Client", method, response)
end
