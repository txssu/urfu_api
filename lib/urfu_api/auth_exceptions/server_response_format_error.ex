defmodule UrFUAPI.AuthExceptions.ServerResponseFormatError do
  @moduledoc false
  defexception [:message]

  @impl Exception
  def exception(%{except: except, got: got}) do
    %__MODULE__{message: "Except #{except}, but got #{inspect(got)}"}
  end
end
