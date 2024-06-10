defmodule UrFUAPI.IStudent.BRS.Group do
  @moduledoc false

  use TypedStruct
  use ExConstructor

  import UrFUAPI.StructUtils

  defmodule Year do
    @moduledoc false

    use TypedStruct
    use ExConstructor

    typedstruct enforce: true do
      field :year, integer()
      field :semesters, [integer()]
    end
  end

  typedstruct enforce: true do
    field :group_id, String.t()
    field :group_title, String.t()

    field :years, [Year.t()]
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> Enum.map(fn {key, value} -> {(key), value} end)
    |> super()
    |> cast_many(:years, Year)
  end
end
