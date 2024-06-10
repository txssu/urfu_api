defmodule UrFUAPI.IStudent.BRS.SubjectInfo do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  import UrFUAPI.StructUtils

  alias UrFUAPI.IStudent.BRS.SubjectEvent

  defmodule Result do
    @moduledoc false
    use TypedStruct
    use ExConstructor

    typedstruct do
      field :mark, String.t()
      field :score, integer()
    end
  end

  typedstruct enforce: true do
    field :id, String.t()

    field :title, String.t()
    field :edu_year, integer()
    field :semester, String.t()
    field :teachers, [String.t()]

    field :result, Result.t()
    field :events, [SubjectEvent.t()]

    field :retake, any()
    field :coursework, any()
    field :remark, any()
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> super()
    |> cast_field(:result, Result)
    |> cast_many(:events, SubjectEvent)
  end
end
