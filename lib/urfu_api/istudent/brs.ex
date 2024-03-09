defmodule UrFUAPI.IStudent.BRS do
  @moduledoc false
  alias UrFUAPI.IStudent.Auth.Token
  alias UrFUAPI.IStudent.BRS.Subject
  alias UrFUAPI.IStudent.BRS.SubjectScore
  alias UrFUAPI.IStudent.Client

  @spec get_subjects(Token.t()) :: {:ok, [Subject.t()]} | {:error, term()}
  def get_subjects(auth) do
    with {:ok, response} <- Client.request_brs(auth) do
      {:ok, parse_subjects(response)}
    end
  end

  defp parse_subjects(body) do
    with {:ok, document} <- Floki.parse_document(body) do
      case Floki.find(document, "a.rating-discipline") do
        [] ->
          {:error, Floki.ParseError.exception("can't find a.rating-discipline")}

        html_subjects ->
          subjects =
            Enum.reduce(html_subjects, [], fn
              _html_subject, {:error, _error} = error ->
                error

              html_subject, acc ->
                case parse_subject(html_subject) do
                  {:ok, subject} -> [subject | acc]
                  {:error, _error} = error -> error
                end
            end)

          {:ok, subjects}
      end
    end
  end

  defp parse_subject(html_subject) do
    with {:ok, id} <- parse_subject_id(html_subject),
         {:ok, name} <- parse_subject_name(html_subject),
         {:ok, total} <- parse_subject_total(html_subject),
         {:ok, grade} <- parse_subject_grade(html_subject) do
      {:ok, Subject.new(id: id, name: name, total: total, grade: grade)}
    end
  end

  defp parse_subject_id(html_subject) do
    case Floki.attribute(html_subject, "id") do
      [elem] ->
        case Integer.parse(elem) do
          {number, ""} -> {:ok, number}
          _error -> {:error, Floki.ParseError.exception(".td-0 is not an integer")}
        end

      _error ->
        {:error, Floki.ParseError.exception("can't find .td-0 for name")}
    end
  end

  defp parse_subject_name(html_subject) do
    case Floki.find(html_subject, ".td-0") do
      [elem] -> {:ok, unpack_text(elem)}
      _error -> {:error, Floki.ParseError.exception("can't find .td-0 for name")}
    end
  end

  defp parse_subject_total(html_subject) do
    case Floki.find(html_subject, ".td-1") do
      [elem] ->
        text = unpack_text(elem)

        case Float.parse(text) do
          {number, ""} -> {:ok, number}
          _error -> {:error, Floki.ParseError.exception(".td-1 total is not a float")}
        end

      _error ->
        {:error, Floki.ParseError.exception("can't find .td-1 for total")}
    end
  end

  defp parse_subject_grade(html_subject) do
    case Floki.find(html_subject, ".td-2") do
      [elem] -> {:ok, unpack_text(elem)}
      _error -> {:error, Floki.ParseError.exception("can't find .td-2 for grade")}
    end
  end

  @spec preload_subject_scores(Token.t(), Subject.t()) :: {:ok, Subject.t()} | {:error, term()}
  def preload_subject_scores(auth, %Subject{id: object_id} = subject) do
    with {:ok, response} <- Client.request_brs(auth, discipline: object_id),
         {:ok, scores} <- parse_subject_scores(response) do
      {:ok, %{subject | scores: scores}}
    end
  end

  defp parse_subject_scores(body) do
    with {:ok, document} <- Floki.parse_document(body) do
      case Floki.find(document, ".brs-countainer") do
        [] ->
          {:error, Floki.ParseError.exception("can't find .brs-countainer")}

        html_subject_scores ->
          subject_scores =
            Enum.reduce(html_subject_scores, [], fn
              _html_subject, {:error, _error} = error ->
                error

              html_subject, acc ->
                case parse_subject_score(html_subject) do
                  {:ok, subject_score} -> [subject_score | acc]
                  {:error, _error} = error -> error
                end
            end)

          {:ok, subject_scores}
      end
    end
  end

  defp parse_subject_score(html_element) do
    html_subject_score = Floki.find(html_element, ".brs-h4")

    with {:ok, name} <- parse_subject_score_name(html_subject_score),
         {:ok, raw} <- parse_subject_score_raw(html_subject_score),
         {:ok, multiplier} <- parse_subject_score_multiplier(html_subject_score),
         {:ok, total} <- parse_subject_score_total(html_subject_score) do
      {:ok, SubjectScore.new(name: name, raw: raw, multiplier: multiplier, total: total)}
    end
  end

  defp parse_subject_score_name(html_subject_score) do
    case Floki.attribute(html_subject_score, "title") do
      [title] -> {:ok, String.capitalize(title)}
      _no_title -> {:error, Floki.ParseError.exception("can't find title attribute for score name")}
    end
  end

  defp parse_subject_score_raw(html_subject_score) do
    parse_subject_score(html_subject_score, ".brs-blue")
  end

  defp parse_subject_score_multiplier(html_subject_score) do
    parse_subject_score(html_subject_score, ".brs-gray")
  end

  defp parse_subject_score_total(html_subject_score) do
    parse_subject_score(html_subject_score, ".brs-green")
  end

  defp parse_subject_score(html_subject_score, class) do
    case Floki.find(html_subject_score, class) do
      [html_score] ->
        score_raw = html_score |> unpack_text() |> Float.parse()

        case score_raw do
          {number, _score} -> {:ok, number}
          _error -> {:error, Floki.ParseError.exception("#{class} score is not a float but #{score_raw}")}
        end

      _no_title ->
        {:error, Floki.ParseError.exception("can't find #{class} for score")}
    end
  end

  defp unpack_text(html_tree) do
    html_tree
    |> Floki.text()
    |> String.trim()
  end
end
