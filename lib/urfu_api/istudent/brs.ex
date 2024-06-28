defmodule UrFUAPI.IStudent.BRS do
  @moduledoc false
  alias UrFUAPI.IStudent.Auth.Token
  alias UrFUAPI.IStudent.BRS.FiltersList
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUAPI.IStudent.BRS.SubjectInfo
  alias UrFUAPI.IStudent.Client

  @spec get_filters(Token.t()) :: {:ok, FiltersList.t()} | {:error, Exception.t()}
  def get_filters(auth) do
    with {:ok, response} <- Client.request_brs_filters(auth) do
      {:ok, FiltersList.new(response)}
    end
  end

  @spec get_subjects(Token.t(), String.t(), integer(), String.t()) :: {:ok, [Subject.t()]} | {:error, Exception.t()}
  def get_subjects(auth, group_id, year, semester) do
    with {:ok, response} <- Client.request_subjects_list(auth, group_id, year, semester) do
      {:ok, Enum.map(response, &Subject.new/1)}
    end
  end

  @spec get_subject(Token.t(), String.t(), integer(), String.t(), String.t()) ::
          {:ok, SubjectInfo.t()} | {:error, Exception.t()}
  def get_subject(auth, group_id, year, semester, subject_id) do
    with {:ok, response} <- Client.request_subject(auth, group_id, year, semester, subject_id) do
      {:ok, SubjectInfo.new(response)}
    end
  end
end
