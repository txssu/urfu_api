defmodule UrFUAPI.Modeus.Persons do
  @moduledoc false
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Client

  @spec search(Token.t(), map()) :: [Person.t()]
  def search(auth, params) do
    body = Map.merge(%{"sort" => "+fullName", "size" => 10, "page" => 0}, params)

    with {:ok, response} <- Client.request_schedule("/people/persons/search", auth, body) do
      %{"_embedded" => data} = response

      {:ok, data}
    end
  end
end
