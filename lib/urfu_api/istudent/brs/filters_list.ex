defmodule UrFUAPI.IStudent.BRS.FiltersList do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  import UrFUAPI.StructUtils

  alias UrFUAPI.IStudent.BRS.Group

  typedstruct enforce: true do
    field :groups, [Group.t()]
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> super()
    |> cast_many(:groups, Group)
  end
end
