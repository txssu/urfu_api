defmodule UrFUAPI.IStudent.Client do
  @moduledoc false

  alias UrFUAPI.IStudent

  @url "https://sso.urfu.ru/adfs/OAuth2/authorize?resource=https%3A%2F%2Fistudent.urfu.ru&type=web_server&client_id=https%3A%2F%2Fistudent.urfu.ru&redirect_uri=https%3A%2F%2Fistudent.urfu.ru%3Fauth&response_type=code&scope="

  @spec request_urfu_sso(Finch.Request.method(), Enumerable.t(), Finch.Request.headers()) ::
          {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def request_urfu_sso(method, body, client_headers) do
    headers = [{"content-type", "application/x-www-form-urlencoded"} | client_headers]

    encoded_body = URI.encode_query(body)

    UrFUAPI.Client.request(method, @url, headers, encoded_body)
  end

  @spec request_istudent_token(Finch.Request.url()) :: {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def request_istudent_token(url) do
    UrFUAPI.Client.request(:get, url)
  end

  @brs_url "https://istudent.urfu.ru/s/http-urfu-ru-ru-students-study-brs"

  @spec request_brs(IStudent.Auth.Token.t(), discipline: integer()) :: {:ok, binary()} | {:error, Exception.t()}
  def request_brs(token, options \\ []) do
    path =
      if discipline_id = Keyword.get(options, :discipline) do
        "/discipline?discipline_id=#{discipline_id}"
      else
        "/"
      end

    url = @brs_url <> path

    with {:ok, %{body: body}} <- UrFUAPI.Client.request(:get, url, headers_with_token(token)) do
      {:ok, body}
    end
  end

  defp headers_with_token(%{access_token: token}) do
    [
      {"content-type", "application/x-www-form-urlencoded"},
      {"cookie", token}
    ]
  end
end
