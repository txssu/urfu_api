defmodule UrFUAPI.Modeus.Client do
  @moduledoc false

  alias UrFUAPI.Modeus.Auth.Token

  @oauth2 "https://urfu-auth.modeus.org/oauth2/authorize?response_type=id_token%20token&client_id=3CuF3FsNyRLiFVj0Il2fIujftw0a&state=Ym1KVy5NWDBXeXhRaU9qUk5HVW1Wb0Z-MVFadmo0c2VNYm9aWlh1OFc2bkxr&redirect_uri=https%3A%2F%2Furfu.modeus.org%2Fschedule-calendar%2Fmy&scope=openid&nonce=0"
  @common_auth "https://urfu-auth.modeus.org/commonauth"

  @modeus_schedule_base "https://urfu.modeus.org/schedule-calendar-v2/api"

  @spec request_schedule!(String.t(), Token.t(), term()) :: term()
  def request_schedule!(path, token, request_body) do
    encoded_body = Jason.encode!(request_body)

    %{body: body} = UrFUAPI.Client.request!(:post, @modeus_schedule_base <> path, headers_with_token(token), encoded_body)

    Jason.decode!(body)
  end

  @spec request_relay_data!() :: Finch.Response.t()
  def request_relay_data! do
    UrFUAPI.Client.request!(:get, @oauth2)
  end

  @spec request_saml_tokens!(Finch.Request.url(), term()) :: Finch.Response.t()
  def request_saml_tokens!(url, body) do
    request_urlencoded!(:post, url, body)
  end

  @spec request_saml_auth!(Finch.Request.url(), [String.t()]) :: Finch.Response.t()
  def request_saml_auth!(url, tokens) do
    headers = [{"cookie", Enum.join(tokens, ";")}]

    UrFUAPI.Client.request!(:get, url, headers)
  end

  @spec request_auth_link!(term()) :: Finch.Response.t()
  def request_auth_link!(body) do
    request_urlencoded!(:post, @common_auth, body)
  end

  @spec auth_with_url(Finch.Request.url()) :: Finch.Response.t()
  def auth_with_url(url) do
    UrFUAPI.Client.request!(:get, url)
  end

  @spec request_urlencoded!(Finch.Request.method(), Finch.Request.url(), term()) :: Finch.Response.t()
  def request_urlencoded!(method, url, body) do
    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    encoded_body = URI.encode_query(body)

    UrFUAPI.Client.request!(method, url, headers, encoded_body)
  end

  defp headers_with_token(%{id_token: id_token}) do
    [
      {"authorization", "Bearer #{id_token}"},
      {"content-type", "application/json"}
    ]
  end
end
