defmodule UrfuApi.Modeus.Persons.Person do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, String.t()
    field :first_name, String.t()
    field :middle_name, String.t()
    field :last_name, String.t()
    field :full_name, String.t()
  end
end
