defmodule UrFUAPI.IStudent.AuthTest do
  use ExUnit.Case, async: true
  use Mimic.DSL

  alias UrFUAPI.IStudent.Auth
  alias UrFUAPI.IStudent.Auth.Token
  alias UrFUAPI.IStudent.Client

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

  describe "sign_in/2" do
    test "returns error on tesla error" do
      expect(Client.request_access_token(_username, _password), do: {:error, :tesla_error})

      assert {:error, :tesla_error} = Auth.sign_in("username", "password")
    end

    test "returns error on invalid_grant" do
      expect(Client.request_access_token(_username, _password),
        do: {:ok, %{"error" => "invalid_grant"}}
      )

      assert {:error, :wrong_credentials} = Auth.sign_in("username", "password")
    end

    test "returns error on success without access_token" do
      expect(Client.request_access_token(_username, _password),
        do: {:ok, %{}}
      )

      assert {:error, :invalid_server_response} = Auth.sign_in("username", "password")
    end

    test "returns ok on success" do
      username = "some-username"
      access_token = "good-token"
      expires_in = 100

      expect(Client.request_access_token(_username, _password),
        do: {:ok, %{"access_token" => access_token, "expires_in" => expires_in}}
      )

      assert {:ok, %Token{access_token: access_token, username: username, expires_in: expires_in}} == Auth.sign_in(username, "password")
    end
  end
end
