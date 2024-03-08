defmodule UrFUAPI.UBU.CommunalChargesTest do
  use ExUnit.Case, async: true

  alias UrFUAPI.UBU.Auth
  alias UrFUAPI.UBU.CommunalCharges

  setup context do
    if context[:api] do
      %{username: username, password: password} = UrFUAPI.Credentials.fetch_from_env()

      {:ok, auth} = Auth.sign_in(username, password)

      %{auth: auth}
    else
      :ok
    end
  end

  @tag :api
  test "get communal charges", %{auth: auth} do
    assert %CommunalCharges.Info{} = CommunalCharges.get_dates(auth)
  end
end
