defmodule UrFUAPI.IStudent.BRS.Attestation do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  import UrFUAPI.StructUtils

  defmodule Control do
    @moduledoc false
    use TypedStruct
    use ExConstructor

    typedstruct enforce: true do
      field :id, String.t()
      field :max_score, integer()
      field :min_score, integer()
      field :score, integer()
      field :title, String.t()
    end

    @spec new(ExConstructor.map_or_kwlist()) :: t()
    def new(fields) do
      fields
      |> Enum.map(fn {key, value} -> {Macro.underscore(key), value} end)
      |> super()
    end
  end

  typedstruct enforce: true do
    field :factor, float()
    field :score_with_factor, integer()
    field :score_without_factor, integer()
    field :type, String.t()

    field :controls, [Control.t()]
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> Enum.map(fn {key, value} -> {Macro.underscore(key), value} end)
    |> super()
    |> cast_many(:controls, Control)
  end
end
