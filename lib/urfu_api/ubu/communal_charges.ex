defmodule UrfuApi.Ubu.CommunalCharges do
  @moduledoc false
  alias UrfuApi.Ubu.Auth.Token
  alias UrfuApi.Ubu.Client
  alias UrfuApi.Ubu.CommunalCharges.Info

  @spec get_dates(Token.t()) :: Info.t()
  def get_dates(auth) do
    auth
    |> Client.exec("CommunalCharges.GetDates")
    |> Info.new()
  end
end
