defmodule UrFUAPI.Modeus.Persons do
  @moduledoc false
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Client
  alias UrFUAPI.Modeus.Persons.Person

  @spec search_person(Token.t(), String.t()) :: [Person.t()]
  def search_person(auth, fullname) do
    body = %{
      "fullName" => fullname,
      "sort" => "+fullName",
      "size" => 10,
      "page" => 0
    }

    %{"_embedded" => %{"persons" => persons}} = Client.request_schedule!("/people/persons/search", auth, body)

    Enum.map(persons, &Person.new/1)
  end
end
