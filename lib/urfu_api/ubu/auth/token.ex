defmodule UrFUAPI.UBU.Auth.Token do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :access_token, String.t()
    field :username, String.t()
  end

  @spec new([String.t()], String.t()) :: t
  def new(cookies, username) do
    %__MODULE__{username: username, access_token: format_cookies(cookies)}
  end

  defp format_cookies(cookies) do
    Enum.map_join(cookies, ";", fn cookie -> cookie |> String.split(";") |> List.first() end)
  end
end
