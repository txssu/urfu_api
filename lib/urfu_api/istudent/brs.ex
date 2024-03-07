defmodule UrfuApi.Istudent.BRS do
  @moduledoc false
  alias UrfuApi.Istudent.Auth.Token
  alias UrfuApi.Istudent.BRS.Subject
  alias UrfuApi.Istudent.BRS.SubjectScore
  alias UrfuApi.Istudent.Client

  @spec get_subjects(Token.t()) :: [Subject.t()]
  def get_subjects(auth) do
    auth
    |> Client.request_brs!()
    |> parse_subjects()
  end

  defp parse_subjects(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find("a.rating-discipline")
    |> Enum.map(&parse_subject/1)
  end

  defp parse_subject(html_subject) do
    Subject.new(
      id: parse_subject_id(html_subject),
      name: parse_subject_name(html_subject),
      total: parse_subject_total(html_subject),
      grade: parse_subject_grade(html_subject)
    )
  end

  defp parse_subject_id(html_subject) do
    html_subject
    |> Floki.attribute("id")
    |> List.first()
    |> String.to_integer()
  end

  defp parse_subject_name(html_subject) do
    html_subject
    |> Floki.find(".td-0")
    |> unpack_text()
  end

  defp parse_subject_total(html_subject) do
    html_subject
    |> Floki.find(".td-1")
    |> unpack_text()
    |> String.to_float()
  end

  defp parse_subject_grade(html_subject) do
    html_subject
    |> Floki.find(".td-2")
    |> unpack_text()
  end

  @spec preload_subject_scores(Token.t(), Subject.t()) :: Subject.t()
  def preload_subject_scores(auth, %Subject{id: object_id} = subject) do
    scores =
      auth
      |> Client.request_brs!(discipline: object_id)
      |> parse_subject_scores()

    %{subject | scores: scores}
  end

  defp parse_subject_scores(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find(".brs-countainer")
    |> Enum.map(&parse_subject_score/1)
  end

  defp parse_subject_score(html_element) do
    html_subject_score = Floki.find(html_element, ".brs-h4")

    SubjectScore.new(
      name: parse_subject_score_name(html_subject_score),
      raw: parse_subject_score_raw(html_subject_score),
      multiplier: parse_subject_score_multiplier(html_subject_score),
      total: parse_subject_score_total(html_subject_score)
    )
  end

  defp parse_subject_score_name(html_subject_score) do
    html_subject_score
    |> Floki.attribute("title")
    |> List.first()
    |> String.capitalize()
  end

  defp parse_subject_score_raw(html_subject_score) do
    html_subject_score
    |> Floki.find(".brs-blue")
    |> unpack_text()
    |> String.to_float()
  end

  defp parse_subject_score_multiplier(html_subject_score) do
    html_subject_score
    |> Floki.find(".brs-gray")
    |> unpack_text()
    |> String.to_float()
  end

  defp parse_subject_score_total(html_subject_score) do
    html_subject_score
    |> Floki.find(".brs-green")
    |> unpack_text()
    |> Float.parse()
    |> elem(0)
  end

  defp unpack_text(html_tree) do
    html_tree
    |> Floki.text()
    |> String.trim()
  end
end
