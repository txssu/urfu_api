defmodule UrFUAPI.UBU.AuthTest do
  use ExUnit.Case, async: true

  alias UrFUAPI.UBU.Auth

  setup context do
    if context[:api] do
      UrFUAPI.Credentials.fetch_from_env()
    else
      :ok
    end
  end

  @tag :api
  test "Auth with valid credentials", %{username: username, password: password} do
    assert {:ok, _auth} = Auth.sign_in(username, password)
  end

  @tag :api
  test "Auth with invalid credentials" do
    assert {:error, _auth} = Auth.sign_in("username", "password")
  end
end
