defmodule UrFUAPI.IStudent.BRSTest do
  use ExUnit.Case, async: true

  alias UrFUAPI.IStudent.Auth
  alias UrFUAPI.IStudent.BRS

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
  test "get brs subjects", %{auth: auth} do
    assert %BRS.Subject{} = auth |> BRS.get_subjects() |> hd()
  end

  @tag :api
  test "update ", %{auth: auth} do
    subject = auth |> BRS.get_subjects() |> hd()

    preloaded_subject = BRS.preload_subject_scores(auth, subject)

    assert preloaded_subject.scores != subject.scores
  end
end
