defmodule UrFUAPI.UBU.AuthTest do
  use ExUnit.Case
  use Patch

  alias UrFUAPI.AuthExceptions.ServerResponseFormatError
  alias UrFUAPI.AuthExceptions.WrongCredentialsError
  alias UrFUAPI.UBU.Auth

  describe "Real API" do
    @describetag :integration

    setup do
      UrFUAPI.Credentials.fetch_from_env()
    end

    test "auths with valid credentials", %{username: username, password: password} do
      assert {:ok, _auth} = Auth.sign_in(username, password)
    end

    test "not auths with invalid credentials" do
      assert {:error, _reason} = Auth.sign_in("username", "password")
    end
  end

  describe "get_auth_tokens/2" do
    test "returns credentials error when not redirected" do
      patch(UrFUAPI.UBU.Client, :request_urfu_sso, {:ok, %{status: 200}})

      assert {:error, %WrongCredentialsError{}} = Auth.get_auth_tokens("username", "password")
    end

    test "returns wrong count of cookies" do
      patch(UrFUAPI.UBU.Client, :request_urfu_sso, {:ok, %{status: 300, headers: [{"set-cookie", "token"}]}})

      assert {:error, %ServerResponseFormatError{}} = Auth.get_auth_tokens("username", "password")
    end

    test "returns two tokens with valid credentials" do
      tokens = ["token1", "token2"]

      cookies = Enum.map(tokens, &{"set-cookie", &1})
      patch(UrFUAPI.UBU.Client, :request_urfu_sso, {:ok, %{status: 300, headers: cookies}})

      assert {:ok, ^tokens} = Auth.get_auth_tokens("username", "password")
    end
  end

  describe "get_auth_url/1" do
    test "returns error when no location in response" do
      patch(UrFUAPI.UBU.Client, :request_urfu_sso, {:ok, %{headers: []}})

      assert {:error, %ServerResponseFormatError{}} = Auth.get_auth_url(["token1", "token2"])
    end

    test "returns auth url when good response" do
      url = "https://example.com"
      patch(UrFUAPI.UBU.Client, :request_urfu_sso, {:ok, %{headers: [{"location", url}]}})

      assert {:ok, ^url} = Auth.get_auth_url(["token1", "token2"])
    end
  end

  describe "get_ubu_login_code/1" do
    test "returns error when no location in response" do
      patch(UrFUAPI.UBU.Client, :request_ubu_code, {:ok, %{headers: []}})

      assert {:error, %ServerResponseFormatError{}} = Auth.get_ubu_login_code("login_code")
    end

    test "returns error when no code in response" do
      url = "https://example.com?not_code=abc"
      patch(UrFUAPI.UBU.Client, :request_ubu_code, {:ok, %{headers: [{"location", url}]}})

      assert {:error, %ServerResponseFormatError{}} = Auth.get_ubu_login_code("login_code")
    end

    test "returns ubu auth code when good response" do
      code = "abc"
      url = "https://example.com?not_code=abc&code=#{code}"
      patch(UrFUAPI.UBU.Client, :request_ubu_code, {:ok, %{headers: [{"location", url}]}})

      assert {:ok, ^code} = Auth.get_ubu_login_code("login_code")
    end
  end

  describe "get_access_token/2" do
    test "returns error when wrong count of tokens" do
      patch(UrFUAPI.UBU.Client, :request_ubu_token, {:ok, %{headers: [{"set-cookie", "token"}]}})

      assert {:error, %ServerResponseFormatError{}} = Auth.get_access_token("code", "username")
    end

    test "returns %Token{} when response is good" do
      tokens = ["token1", "token2"]
      cookies = Enum.map(tokens, &{"set-cookie", &1})
      patch(UrFUAPI.UBU.Client, :request_ubu_token, {:ok, %{headers: cookies}})

      assert {:ok, %Auth.Token{}} = Auth.get_access_token("code", "username")
    end
  end

  test "sign_in/2 returns token" do
    tokens = ["token1", "token2"]
    cookies = Enum.map(tokens, &{"set-cookie", &1})
    url = "https://example.com?not_code=abc&code=abc"

    patch(
      UrFUAPI.UBU.Client,
      :request_urfu_sso,
      sequence([
        {:ok, %{status: 300, headers: cookies}},
        {:ok, %{headers: [{"location", url}]}}
      ])
    )

    patch(
      UrFUAPI.UBU.Client,
      :request_ubu_code,
      {:ok, %{headers: [{"location", url}]}}
    )

    patch(UrFUAPI.UBU.Client, :request_ubu_token, {:ok, %{headers: cookies}})

    assert {:ok, %Auth.Token{}} = Auth.sign_in("username", "password")
  end
end
