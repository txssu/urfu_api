defmodule UrFUAPI.IStudent.Client do
  @moduledoc false
  alias UrFUAPI.IStudent.Auth.Token

  @type client_response :: {:ok, json :: map()} | {:error, Exception.t()}

  @spec request_access_token(String.t(), String.t()) :: client_response
  def request_access_token(username, password) do
    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    body = URI.encode_query(%{client_id: "urfu_study", grant_type: "password", username: username, password: password})

    :post
    |> UrFUAPI.Client.request("https://keys.urfu.ru/auth/realms/urfu-lk/protocol/openid-connect/token", headers, body)
    |> handle_response()
  end

  @spec request_brs_filters(Token.t()) :: client_response
  def request_brs_filters(token) do
    :get
    |> UrFUAPI.Client.request("https://urfu-study-api.my1.urfu.ru/api/brs/filters?", headers_with_token(token))
    |> handle_response()
  end

  @spec request_subjects_list(Token.t(), String.t(), integer(), String.t()) :: client_response
  def request_subjects_list(token, group_id, year, semester) do
    :get
    |> UrFUAPI.Client.request(
      "https://urfu-study-api.my1.urfu.ru/api/brs/disciplines/#{year}/#{semester}?groupId=#{group_id}",
      headers_with_token(token)
    )
    |> handle_response()
  end

  @spec request_subject(Token.t(), String.t(), integer(), String.t(), String.t()) :: client_response
  def request_subject(token, group_id, year, semester, subject_id) do
    :get
    |> UrFUAPI.Client.request(
      "https://urfu-study-api.my1.urfu.ru/api/brs/disciplines/#{year}/#{semester}/#{subject_id}?groupId=#{group_id}",
      headers_with_token(token)
    )
    |> handle_response()
  end

  defp handle_response({:ok, %{body: body}}), do: Jason.decode(body)
  defp handle_response(error), do: error

  defp headers_with_token(%{access_token: token}) do
    [
      {"authorization", "Bearer #{token}"}
    ]
  end
end
