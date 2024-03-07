defmodule UrFUAPI.IStudent.BRS.SubjectScore do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :name, String.t()
    field :raw, float()
    field :multiplier, float()
    field :total, float()
  end
end
