defmodule UrFUAPI.UBU.Client do
  @moduledoc false

  alias UrFUAPI.UBU.Auth.Token

  @url "https://sso.urfu.ru/adfs/OAuth2/authorize?client_id=https%3A%2F%2Fubu.urfu.ru%2Ffse&redirect_uri=https%3A%2F%2Fubu.urfu.ru%2Ffse&resource=https%3A%2F%2Fubu.urfu.ru%2Ffse&response_type=code&state=e30"
  @rpc_url "https://ubu.urfu.ru/fse/api/rpc"

  @spec exec(Token.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def exec(token, method_name) do
    with {:ok, encoded_body} <- Jason.encode(%{method: method_name}),
         {:ok, %{body: body}} <- UrFUAPI.Client.request(:post, @rpc_url, headers_with_token(token), encoded_body),
         {:ok, %{"result" => result}} <- Jason.decode(body) do
      {:ok, result}
    end
  end

  @spec request_urfu_sso(Finch.Request.method(), Enumerable.t(), Finch.Request.headers()) ::
          {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def request_urfu_sso(method, body, client_headers) do
    headers = [{"content-type", "application/x-www-form-urlencoded"} | client_headers]

    encoded_body = URI.encode_query(body)

    UrFUAPI.Client.request(method, @url, headers, encoded_body)
  end

  @spec request_ubu_code(Finch.Request.url()) :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def request_ubu_code(url) do
    UrFUAPI.Client.request(:get, url)
  end

  @spec request_ubu_token(term()) :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def request_ubu_token(body) do
    headers = [{"content-type", "application/json"}]

    with {:ok, encoded_body} <- Jason.encode(body) do
      UrFUAPI.Client.request(:post, @rpc_url, headers, encoded_body)
    end
  end

  defp headers_with_token(%{access_token: token}) do
    [
      {"content-type", "application/json"},
      {"cookie", token}
    ]
  end
end
