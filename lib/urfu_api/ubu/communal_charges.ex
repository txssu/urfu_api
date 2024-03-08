defmodule UrFUAPI.UBU.CommunalCharges do
  @moduledoc false
  alias UrFUAPI.UBU.Auth.Token
  alias UrFUAPI.UBU.Client
  alias UrFUAPI.UBU.CommunalCharges.Info

  @spec get_dates(Token.t()) :: {:ok, Info.t()} | {:error, term()}
  def get_dates(auth) do
    with {:ok, response} <- Client.exec(auth, "CommunalCharges.GetDates") do
      {:ok, Info.new(response)}
    end
  end
end
