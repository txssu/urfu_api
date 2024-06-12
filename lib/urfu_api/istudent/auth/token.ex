defmodule UrFUAPI.IStudent.Auth.Token do
  @moduledoc false
  use TypedStruct
  use ExConstructor, name: :__exconstructor_new__

  typedstruct enforce: true do
    field :access_token, String.t()
    field :username, String.t()
    field :expires_in, integer()
  end

  @spec new(String.t(), ExConstructor.map_or_kwlist()) :: t()
  def new(username, fields) do
    fields
    |> __exconstructor_new__()
    |> Map.put(:username, username)
  end
end
