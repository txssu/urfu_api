defmodule UrFUAPI.Modeus.Auth do
  @moduledoc false
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.Modeus
  alias UrFUAPI.Modeus.Auth.Token

  defmodule AuthProcess do
    @moduledoc false
    defstruct ~w[relay_url relay_state saml_tokens saml_response]a

    @type t :: %__MODULE__{
            relay_url: String.t() | nil,
            relay_state: String.t() | nil,
            saml_tokens: [String.t()] | nil,
            saml_response: String.t() | nil
          }

    @spec new :: t()
    def new, do: %__MODULE__{}
  end

  @spec sign_in(String.t(), String.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def sign_in(username, password) do
    process =
      AuthProcess.new()
      |> get_relay_data()
      |> get_saml_tokens(username, password)

    case process do
      {:ok, process} ->
        token =
          process
          |> get_saml_response()
          |> get_id_token(username)

        {:ok, token}

      err ->
        err
    end
  end

  @spec get_relay_data(AuthProcess.t()) :: AuthProcess.t()
  defp get_relay_data(%AuthProcess{} = process) do
    response = Modeus.Client.request_relay_data!()

    response
    |> AuthHelpers.fetch_location!()
    |> insert_relay_data(process)
  end

  @spec insert_relay_data(String.t(), AuthProcess.t()) :: AuthProcess.t()
  defp insert_relay_data(relay_url, %AuthProcess{} = process) do
    process
    |> Map.put(:relay_url, relay_url)
    |> Map.put(:relay_state, fetch_relay_state(relay_url))
  end

  @spec fetch_relay_state(String.t()) :: String.t()
  defp fetch_relay_state(relay_url) do
    relay_url
    |> URI.parse()
    |> Map.fetch!(:query)
    |> URI.decode_query()
    |> Map.fetch!("RelayState")
  end

  @spec get_saml_tokens(AuthProcess.t(), String.t(), String.t()) ::
          {:ok, AuthProcess.t()} | {:error, String.t()}
  defp get_saml_tokens(%AuthProcess{relay_url: url} = process, username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    response = Modeus.Client.request_saml_tokens!(url, body)

    case AuthHelpers.ensure_redirect(response) do
      {:ok, response} ->
        process =
          response
          |> AuthHelpers.fetch_cookies!()
          |> insert_saml_tokens(process)

        {:ok, process}

      :error ->
        {:error, "Wrong credentials"}
    end
  end

  @spec insert_saml_tokens([String.t()], AuthProcess.t()) :: AuthProcess.t()
  defp insert_saml_tokens(saml_tokens, %AuthProcess{} = process) do
    Map.put(process, :saml_tokens, saml_tokens)
  end

  @spec get_saml_response(AuthProcess.t()) :: AuthProcess.t()
  defp get_saml_response(%AuthProcess{relay_url: url, saml_tokens: tokens} = process) do
    url
    |> Modeus.Client.request_saml_auth!(tokens)
    |> parse_saml_response()
    |> insert_saml_response(process)
  end

  @spec insert_saml_response(String.t(), AuthProcess.t()) :: AuthProcess.t()
  defp insert_saml_response(saml_response, %AuthProcess{} = process) do
    Map.put(process, :saml_response, saml_response)
  end

  @spec parse_saml_response(Finch.Response.t()) :: String.t()
  defp parse_saml_response(%{body: body}) do
    body
    |> Floki.parse_document!()
    |> Floki.attribute("input[name=SAMLResponse]", "value")
    |> List.first()
  end

  @spec get_id_token(AuthProcess.t(), String.t()) :: map()
  defp get_id_token(process, username) do
    process
    |> get_auth_url()
    |> parse_auth_url()
    |> Map.put(:username, username)
    |> Token.new()
  end

  @spec get_auth_url(AuthProcess.t()) :: String.t()
  defp get_auth_url(%AuthProcess{saml_response: saml_response, relay_state: relay_state}) do
    body = %{
      "SAMLResponse" => saml_response,
      "RelayState" => relay_state
    }

    body
    |> Modeus.Client.request_auth_link!()
    |> AuthHelpers.fetch_location!()
    |> Modeus.Client.auth_with_url()
    |> AuthHelpers.fetch_location!()
  end

  @spec parse_auth_url(String.t()) :: %{optional(binary) => binary}
  defp parse_auth_url("#" <> data) do
    URI.decode_query(data)
  end

  defp parse_auth_url(<<_ignored::utf8, rest::binary>>) do
    parse_auth_url(rest)
  end
end
