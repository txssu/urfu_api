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
      field :max_score, number()
      field :min_score, number()
      field :score, number()
      field :title, String.t()
    end

    @spec new(ExConstructor.map_or_kwlist()) :: t()
    def new(fields) do
      super(fields)
    end
  end

  typedstruct enforce: true do
    field :factor, float()
    field :score_with_factor, number()
    field :score_without_factor, number()
    field :type, String.t()

    field :controls, [Control.t()]
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> super()
    |> cast_many(:controls, Control)
  end
end
