defmodule UrFUAPI.IStudent.Auth do
  @moduledoc false
  alias UrFUAPI.IStudent
  alias UrFUAPI.IStudent.Auth.Token
  alias UrfuApi.Utils

  require Logger

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, Exception.t()}
  def sign_in(username, password) do
    with {:ok, response} <- IStudent.Client.request_access_token(username, password),
         :ok <- check_invalid_grant(response) do
      token = Token.new(username, response)

      if valid_token?(token) do
        {:ok, token}
      else
        server_error(response)
      end
    end
  end

  defp check_invalid_grant(response) do
    case Map.fetch(response, "error") do
      {:ok, "invalid_grant"} -> {:error, :wrong_credentials}
      {:ok, error} -> {:error, error}
      :error -> :ok
    end
  end

  defp valid_token?(token) do
    token
    |> Map.values()
    |> Enum.any?(&is_nil/1)
    |> Kernel.not()
  end

  defp server_error(response) do
    "request_access_token(:post, ...)"
    |> format_error(response)
    |> Logger.error()

    {:error, :invalid_server_response}
  end

  defp format_error(method, response), do: Utils.invalid_response_format_error("IStudent.Client", method, response)
end
