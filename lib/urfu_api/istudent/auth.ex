defmodule UrFUAPI.IStudent.Auth do
  @moduledoc false
  alias UrFUAPI.IStudent
  alias UrFUAPI.IStudent.Auth.Token
  alias UrfuApi.Utils

  require Logger

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, Exception.t()}
  def sign_in(username, password) do
    with {:ok, response} <- IStudent.Client.request_access_token(username, password) do
      case Map.fetch(response, "access_token") do
        {:ok, access_token} ->
          {:ok, Token.new(access_token, username)}

        :error ->
          maybe_server_error(response)
      end
    end
  end

  defp maybe_server_error(%{"error" => "invalid_grant"}) do
    {:error, :wrong_credentials}
  end

  defp maybe_server_error(response) do
    "request_access_token(:post, ...)"
    |> format_error(response)
    |> Logger.error()

    {:error, :invalid_server_response}
  end

  defp format_error(method, response), do: Utils.invalid_response_format_error("IStudent.Client", method, response)
end
