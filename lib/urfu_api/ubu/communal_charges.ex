defmodule UrfuApi.UBU.CommunalCharges do
  @moduledoc false
  alias UrfuApi.UBU.Auth.Token
  alias UrfuApi.UBU.Client
  alias UrfuApi.UBU.CommunalCharges.Info

  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    auth
    |> Client.exec("CommunalCharges.GetDates")
    |> Info.new()
  end
end
