defmodule UrFUAPI.IStudent.BRS.SubjectEvent do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  import UrFUAPI.StructUtils

  alias UrFUAPI.IStudent.BRS.Attestation

  typedstruct enforce: true do
    field :score_with_factor, number()
    field :score_without_factor, number()
    field :test_before_exam, boolean()
    field :total_factor, number()
    field :type, String.t()
    field :type_title, String.t()

    field :attestations, [Attestation.t()]
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> super()
    |> cast_many(:attestations, Attestation)
  end
end
