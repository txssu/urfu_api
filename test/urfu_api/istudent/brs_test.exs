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
  test "integration test passes", %{auth: auth} do
    assert {:ok, filters} = BRS.get_filters(auth)

    group = List.last(filters.groups)
    group_id = group.group_id
    year_info = List.last(group.years)
    year = year_info.year
    semester = List.last(year_info.semesters)

    assert {:ok, subjects} = BRS.get_subjects(auth, group_id, year, semester)

    subject_id = subjects |> List.last() |> Map.fetch!(:id)

    assert {:ok, _subject} = BRS.get_subject(auth, group_id, year, semester, subject_id)
  end
end
