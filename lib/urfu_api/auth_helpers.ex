defmodule UrfuApi.AuthHelpers do
  @moduledoc false
  @spec ensure_redirect(Finch.Response.t()) :: {:ok, Finch.Response.t()} | :error
  def ensure_redirect(response)

  def ensure_redirect(%{status: status} = response) when status >= 300 and status < 400 do
    {:ok, response}
  end

  def ensure_redirect(_not_redirect), do: :error

  @spec fetch_location!(Finch.Response.t()) :: String.t()
  def fetch_location!(%{} = env) do
    fetch_header!(env, "location")
  end

  @spec fetch_cookies!(Finch.Response.t()) :: [String.t()]
  def fetch_cookies!(%{} = env) do
    fetch_headers!(env, "set-cookie")
  end

  @spec fetch_cookie!(Finch.Response.t()) :: String.t()
  def fetch_cookie!(%{} = env) do
    fetch_header!(env, "set-cookie")
  end

  @spec fetch_header!(Finch.Response.t(), String.t()) :: String.t()
  def fetch_header!(%{headers: headers}, key) do
    headers
    |> List.keyfind!(key, 0)
    |> elem(1)
  end

  @spec fetch_headers!(Finch.Response.t(), String.t()) :: [String.t()]
  def fetch_headers!(%{headers: headers}, key) do
    maybe_headers = for {k, v} <- headers, k == key, do: v

    if Enum.empty?(maybe_headers) do
      headers = inspect(headers)
      raise "There's no #{key} in #{headers}"
    else
      maybe_headers
    end
  end
end
