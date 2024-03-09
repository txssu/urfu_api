defmodule UrFUAPI.IStudent.Auth do
  @moduledoc false
  alias UrFUAPI.AuthExceptions.ServerResponseFormatError
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.IStudent
  alias UrFUAPI.IStudent.Auth.Token

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, Exception.t()}
  def sign_in(username, password) do
    with {:ok, auth_tokens} <- get_auth_tokens(username, password),
         {:ok, auth_url} <- get_auth_url(auth_tokens) do
      get_access_token(auth_url, username)
    end
  end

  defp get_auth_tokens(username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    with {:ok, response} <- IStudent.Client.request_urfu_sso(:post, body, []),
         {:ok, response_good_credentials} <- AuthHelpers.ensure_correct_credentials(response) do
      case AuthHelpers.fetch_cookies(response_good_credentials) do
        [_c1, _c2] = cookies -> {:ok, cookies}
        wrong_data -> {:error, ServerResponseFormatError.exception(%{except: "two cookies", got: wrong_data})}
      end
    end
  end

  defp get_auth_url(tokens) do
    cookies = Enum.join(tokens, ";")

    with {:ok, response} <- IStudent.Client.request_urfu_sso(:get, [], [{"cookie", cookies}]) do
      case AuthHelpers.fetch_location(response) do
        :error -> {:error, ServerResponseFormatError.exception(%{except: "auth url in location", got: response})}
        {:ok, _url} = ok -> ok
      end
    end
  end

  defp get_access_token(url, username) do
    with {:ok, response} <- IStudent.Client.request_istudent_token(url) do
      case AuthHelpers.fetch_cookie(response) do
        :error -> {:error, ServerResponseFormatError.exception(%{except: "url with token", got: response})}
        {:ok, token_data} -> {:ok, Token.new(token_data, username)}
      end
    end
  end
end
