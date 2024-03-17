defmodule UrFUAPI.IStudent.BRSTest do
  use ExUnit.Case, async: true

  alias UrFUAPI.IStudent.Auth
  alias UrFUAPI.IStudent.BRS

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
  test "get brs subjects", %{auth: auth} do
    assert {:ok, subjects} = BRS.get_subjects(auth)
    assert %BRS.Subject{} = hd(subjects)
  end

  @tag :integration
  test "update ", %{auth: auth} do
    {:ok, subjects} = BRS.get_subjects(auth)
    subject = hd(subjects)

    {:ok, preloaded_subject} = BRS.preload_subject_scores(auth, subject)
    assert preloaded_subject.scores != subject.scores
  end
end
