defmodule UrFUAPI.IStudent.BRS.Subject do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, integer()
    field :group_id, String.t()
    field :group_title, String.t()
    field :score, integer()
    field :semester, String.t()
    field :summary_title, String.t()
    field :title, String.t()
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> Enum.map(fn {key, value} -> {Macro.underscore(key), value} end)
    |> super()
  end
end
