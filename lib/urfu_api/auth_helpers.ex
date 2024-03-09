defmodule UrFUAPI.AuthHelpers do
  @moduledoc false

  alias UrFUAPI.AuthExceptions.WrongCredentialsError

  @spec ensure_redirect(Finch.Response.t()) :: {:ok, Finch.Response.t()} | :error
  def ensure_redirect(response)

  def ensure_redirect(%{status: status} = response) when status >= 300 and status < 400 do
    {:ok, response}
  end

  def ensure_redirect(_not_redirect), do: :error

  @spec fetch_location(Finch.Response.t()) :: {:ok, String.t()} | :error
  def fetch_location(%{} = env) do
    fetch_header(env, "location")
  end

  @spec fetch_cookies(Finch.Response.t()) :: [String.t()]
  def fetch_cookies(%{} = env) do
    fetch_headers(env, "set-cookie")
  end

  @spec fetch_cookie(Finch.Response.t()) :: {:ok, String.t()} | :error
  def fetch_cookie(%{} = env) do
    fetch_header(env, "set-cookie")
  end

  @spec fetch_header(Finch.Response.t(), String.t()) :: {:ok, String.t()} | :error
  def fetch_header(%{headers: headers}, key) do
    case List.keyfind(headers, key, 0) do
      nil -> :error
      value -> {:ok, elem(value, 1)}
    end
  end

  @spec fetch_headers(Finch.Response.t(), String.t()) :: [String.t()]
  def fetch_headers(%{headers: headers}, key) do
    for {k, v} <- headers, k == key, do: v
  end

  @spec ensure_correct_credentials(Finch.Response.t()) :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def ensure_correct_credentials(response) do
    case ensure_redirect(response) do
      :error -> {:error, WrongCredentialsError.exception(nil)}
      {:ok, _response} = ok -> ok
    end
  end
end
