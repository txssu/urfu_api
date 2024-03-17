defmodule UrFUAPI.AuthExceptions.WrongCredentialsError do
  @moduledoc false
  defexception [:message]

  @impl Exception
  def exception(_value) do
    %__MODULE__{message: "Passed wrong credentials"}
  end
end
