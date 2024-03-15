defmodule UrFUAPI.UBU.Auth do
  @moduledoc false
  alias UrFUAPI.AuthExceptions.ServerResponseFormatError
  alias UrFUAPI.AuthExceptions.WrongCredentialsError
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.UBU
  alias UrFUAPI.UBU.Auth.Token

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
         {:ensure_redirect, {:ok, response_good_credentials}} <-
           {:ensure_redirect, AuthHelpers.ensure_redirect(response)},
         {:fetch_cookies, [_c1, _c2] = cookies} <- {:fetch_cookies, AuthHelpers.fetch_cookies(response_good_credentials)} do
      {:ok, cookies}
    else
      {:fetch_cookies, wrong_data} ->
        {:error, ServerResponseFormatError.exception(%{except: "two cookies", got: wrong_data})}

      {:ensure_redirect, :error} ->
        {:error, WrongCredentialsError.exception(nil)}

      err ->
        err
    end
  end

  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    with {:ok, response} <- UBU.Client.request_urfu_sso(:get, [], [{"cookie", cookies}]) do
      AuthHelpers.fetch_location(response)
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
        nil -> {:error, ServerResponseFormatError.exception(%{except: "query with ubu code", got: response})}
        code -> {:ok, code}
      end
    end
  end

  defp fetch_location_query(response) do
    case AuthHelpers.fetch_location(response) do
      :error ->
        {:error, ServerResponseFormatError.exception(%{except: "url to get ubu code", got: response})}

      {:ok, location} ->
        %{query: query} = URI.parse(location)
        {:ok, URI.query_decoder(query)}
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
        [_c1, _c2] = cookies -> {:ok, Token.new(cookies, username)}
        cookies -> {:error, ServerResponseFormatError.exception(%{except: "two auth cookies", got: cookies})}
      end
    end
  end
end
