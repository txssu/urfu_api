defmodule UrFUAPI.UBU.CommunalCharges do
  @moduledoc false
  alias UrFUAPI.UBU.Auth.Token
  alias UrFUAPI.UBU.Client
  alias UrFUAPI.UBU.CommunalCharges.Info

  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    auth
    |> Client.exec("CommunalCharges.GetDates")
    |> Info.new()
  end
end
