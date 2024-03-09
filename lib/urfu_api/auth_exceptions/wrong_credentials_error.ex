defmodule UrFUAPI.AuthExceptions.WrongCredentialsError do
  defexception [:message]

  @impl Exception
  def exception(_value) do
    %__MODULE__{message: "Passed wrong credentials"}
  end
end
