defmodule UrfuApi.UBU.Client do
  @moduledoc false

  alias UrfuApi.UBU.Auth.Token

  @url "https://sso.urfu.ru/adfs/OAuth2/authorize?client_id=https%3A%2F%2Fubu.urfu.ru%2Ffse&redirect_uri=https%3A%2F%2Fubu.urfu.ru%2Ffse&resource=https%3A%2F%2Fubu.urfu.ru%2Ffse&response_type=code&state=e30"
  @rpc_url "https://ubu.urfu.ru/fse/api/rpc"

  @spec exec(Token.t(), String.t()) :: term()
  def exec(token, method_name) do
    encoded_body = Jason.encode!(%{method: method_name})

    %{body: body} = UrfuApi.Client.request!(:post, @rpc_url, headers_with_token(token), encoded_body)

    %{"result" => result} = Jason.decode!(body)

    result
  end

  @spec request_urfu_sso!(Finch.Request.method(), Enumerable.t(), Finch.Request.headers()) :: Finch.Response.t()
  def request_urfu_sso!(method, body, client_headers) do
    headers = [{"content-type", "application/x-www-form-urlencoded"} | client_headers]

    encoded_body = URI.encode_query(body)

    UrfuApi.Client.request!(method, @url, headers, encoded_body)
  end

  @spec request_ubu_code!(Finch.Request.url()) :: Finch.Response.t()
  def request_ubu_code!(url) do
    UrfuApi.Client.request!(:get, url)
  end

  @spec request_ubu_token!(term()) :: Finch.Response.t()
  def request_ubu_token!(body) do
    headers = [{"content-type", "application/json"}]

    encoded_body = Jason.encode!(body)

    UrfuApi.Client.request!(:post, @rpc_url, headers, encoded_body)
  end

  defp headers_with_token(%{access_token: token}) do
    [
      {"content-type", "application/json"},
      {"cookie", token}
    ]
  end
end
