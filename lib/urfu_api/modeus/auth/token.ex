defmodule UrFUAPI.Modeus.Auth.Token do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  alias UrFUAPI.Modeus.Auth.TokenClaims

  typedstruct enforce: true do
    field :access_token, String.t()
    field :expires_in, pos_integer()
    field :id_token, String.t()
    field :session_state, String.t()
    field :state, String.t()
    field :token_type, String.t()
    field :claims, map()

    field :username, String.t()
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> super()
    |> put_expires_in()
    |> put_claims()
  end

  @spec put_expires_in(t()) :: t()
  defp put_expires_in(token) do
    Map.update!(token, :expires_in, &String.to_integer/1)
  end

  @spec put_claims(t()) :: t()
  defp put_claims(%__MODULE__{id_token: id_token} = token) do
    {:ok, claims} = Joken.peek_claims(id_token)

    %{token | claims: TokenClaims.new(claims)}
  end
end
