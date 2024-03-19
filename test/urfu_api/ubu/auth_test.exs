defmodule UrFUAPI.UBU.AuthTest do
  use ExUnit.Case
  use Mimic.DSL

  alias UrFUAPI.UBU.Auth
  alias UrFUAPI.UBU.Client

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
      expect(Client.request_urfu_sso(_method, _body, _client), do: {:ok, %{status: 200}})

      assert {:error, :wrong_credentials} = Auth.get_auth_tokens("username", "password")
    end

    test "returns wrong count of cookies" do
      expect(Client.request_urfu_sso(_method, _body, _client),
        do: {:ok, %{status: 300, headers: [{"set-cookie", "token"}]}}
      )

      assert {:error, :invalid_server_response} = Auth.get_auth_tokens("username", "password")
    end

    test "returns two tokens with valid credentials" do
      tokens = ["token1", "token2"]

      cookies = Enum.map(tokens, &{"set-cookie", &1})
      expect(Client.request_urfu_sso(_method, _body, _client), do: {:ok, %{status: 300, headers: cookies}})

      assert {:ok, ^tokens} = Auth.get_auth_tokens("username", "password")
    end
  end

  describe "get_auth_url/1" do
    test "returns error when no location in response" do
      expect(Client.request_urfu_sso(_method, _body, _headers), do: {:ok, %{headers: []}})

      assert {:error, :invalid_server_response} = Auth.get_auth_url(["token1", "token2"])
    end

    test "returns auth url when good response" do
      url = "https://example.com"
      expect(Client.request_urfu_sso(_method, _body, _headers), do: {:ok, %{headers: [{"location", url}]}})

      assert {:ok, ^url} = Auth.get_auth_url(["token1", "token2"])
    end
  end

  describe "get_ubu_login_code/1" do
    test "returns error when no location in response" do
      expect(Client.request_ubu_code(_url), do: {:ok, %{headers: []}})

      assert {:error, :invalid_server_response} = Auth.get_ubu_login_code("login_code")
    end

    test "returns error when no code in response" do
      url = "https://example.com?not_code=abc"
      expect(Client.request_ubu_code(_url), do: {:ok, %{headers: [{"location", url}]}})

      assert {:error, :invalid_server_response} = Auth.get_ubu_login_code("login_code")
    end

    test "returns ubu auth code when good response" do
      code = "abc"
      url = "https://example.com?not_code=abc&code=#{code}"
      expect(Client.request_ubu_code(_url), do: {:ok, %{headers: [{"location", url}]}})

      assert {:ok, ^code} = Auth.get_ubu_login_code("login_code")
    end
  end

  describe "get_access_token/2" do
    test "returns error when wrong count of tokens" do
      expect(Client.request_ubu_token(_body), do: {:ok, %{headers: [{"set-cookie", "token"}]}})

      assert {:error, :invalid_server_response} = Auth.get_access_token("code", "username")
    end

    test "returns %Token{} when response is good" do
      tokens = ["token1", "token2"]
      cookies = Enum.map(tokens, &{"set-cookie", &1})
      expect(Client.request_ubu_token(_body), do: {:ok, %{headers: cookies}})

      assert {:ok, %Auth.Token{}} = Auth.get_access_token("code", "username")
    end
  end

  test "sign_in/2 returns token" do
    tokens = ["token1", "token2"]
    cookies = Enum.map(tokens, &{"set-cookie", &1})
    url = "https://example.com?not_code=abc&code=abc"

    expect Client.request_urfu_sso(_method, _body, _headers) do
      {:ok, %{status: 300, headers: cookies}}
    end

    expect Client.request_urfu_sso(_method, _body, _headers) do
      {:ok, %{headers: [{"location", url}]}}
    end

    expect(Client.request_ubu_code(_url), do: {:ok, %{headers: [{"location", url}]}})

    expect(Client.request_ubu_token(_body), do: {:ok, %{headers: cookies}})

    assert {:ok, %Auth.Token{}} = Auth.sign_in("username", "password")
  end
end
