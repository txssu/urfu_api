defmodule UrFUAPI.Modeus.ScheduleTest do
  use ExUnit.Case, async: true

  alias UrFUAPI.Modeus.Auth
  alias UrFUAPI.Modeus.Schedule

  setup context do
    if context[:integration] do
      %{username: username, password: password} = UrFUAPI.Credentials.fetch_from_env()

      {:ok, auth} = Auth.sign_in(username, password)

      %{auth: auth}
    else
      :ok
    end
  end

  @tag :integration
  test "get schedule", %{auth: auth} do
    assert {:ok, %Schedule.ScheduleData{}} =
             Schedule.get_schedule(auth, ~U[2023-12-01 00:00:00Z], ~U[2023-12-02 00:00:00Z])
  end
end
