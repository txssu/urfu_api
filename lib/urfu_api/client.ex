defmodule UrFUAPI.Client do
  @moduledoc false

  @spec build(
          Finch.Request.method(),
          Finch.Request.url(),
          Finch.Request.headers(),
          Finch.Request.body(),
          Keyword.t()
        ) :: Finch.Request.t()

  def build(method, url, headers, body, opts) do
    Finch.build(method, url, headers, body, opts)
  end

  @spec request(
          Finch.Request.method(),
          Finch.Request.url(),
          Finch.Request.headers(),
          Finch.Request.body(),
          Keyword.t()
        ) :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def request(method, url, headers \\ [], body \\ nil, opts \\ []) do
    method
    |> build(url, headers, body, opts)
    |> Finch.request(__MODULE__)
  end
end
