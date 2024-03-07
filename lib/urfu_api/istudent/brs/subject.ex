defmodule UrFUAPI.IStudent.BRS.Subject do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  alias UrFUAPI.IStudent.BRS.SubjectScore

  typedstruct enforce: true do
    field :id, pos_integer()
    field :name, String.t()
    field :total, float()
    field :grade, String.t()
    field :scores, [SubjectScore.t()] | nil
  end
end
