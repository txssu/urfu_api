defmodule UrFUAPI.IStudent.BRS.Subject do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, String.t()
    field :group_id, String.t()
    field :group_title, String.t()
    field :score, number()
    field :semester, String.t()
    field :summary_title, String.t()
    field :title, String.t()
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    super(fields)
  end
end
