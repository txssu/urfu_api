defmodule UrFUAPI.Modeus.Auth do
  @moduledoc false
  alias UrFUAPI.AuthHelpers
  alias UrFUAPI.Modeus
  alias UrFUAPI.Modeus.Auth.Token
  alias UrfuApi.Utils

  require Logger

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
    with {:ok, process} <- get_relay_data(AuthProcess.new()),
         {:ok, process} <- get_saml_tokens(process, username, password),
         {:ok, process} <- get_saml_response(process) do
      get_id_token(process, username)
    end
  end

  defp get_relay_data(%AuthProcess{} = process) do
    with {:ok, response} <- Modeus.Client.request_relay_data() do
      case AuthHelpers.fetch_location(response) do
        {:ok, url} ->
          insert_relay_data(process, url)

        :error ->
          "request_relay_data(...)"
          |> format_error(response)
          |> Logger.error()

          {:error, :invalid_server_response}
      end
    end
  end

  defp insert_relay_data(%AuthProcess{} = process, relay_url) do
    with {:ok, relay_state} <- fetch_relay_state(relay_url) do
      process =
        process
        |> Map.put(:relay_url, relay_url)
        |> Map.put(:relay_state, relay_state)

      {:ok, process}
    end
  end

  defp fetch_relay_state(relay_url) do
    query =
      relay_url
      |> URI.parse()
      |> Map.fetch!(:query)
      |> URI.decode_query()

    case Map.fetch(query, "RelayState") do
      {:ok, _relay_state} = ok ->
        ok

      :error ->
        Logger.error("Modeus returns relay data, but without RelayState in it.")
        {:error, :invalid_server_response}
    end
  end

  defp get_saml_tokens(%AuthProcess{relay_url: url} = process, username, password) do
    body = %{
      "UserName" => username,
      "Password" => password,
      "AuthMethod" => "FormsAuthentication"
    }

    with {:ok, response} <- Modeus.Client.request_saml_tokens(url, body),
         {:ok, response_good_credentials} <- ensure_auth_ok(response),
         {:ok, tokens} <- fetch_auth_cookies(response_good_credentials) do
      {:ok, insert_saml_tokens(process, tokens)}
    end
  end

  defp ensure_auth_ok(response) do
    case AuthHelpers.ensure_redirect(response) do
      {:ok, _response} = ok -> ok
      :error -> {:error, :wrong_credentials}
    end
  end

  defp fetch_auth_cookies(response) do
    case AuthHelpers.fetch_cookies(response) do
      [_c1, _c2] = cookies ->
        {:ok, cookies}

      _wrong_data ->
        "request_saml_tokens(...)"
        |> format_error(response)
        |> Logger.error()

        {:error, :invalid_server_response}
    end
  end

  defp insert_saml_tokens(%AuthProcess{} = process, saml_tokens) do
    Map.put(process, :saml_tokens, saml_tokens)
  end

  defp get_saml_response(%AuthProcess{relay_url: url, saml_tokens: tokens} = process) do
    with {:ok, response} <- Modeus.Client.request_saml_auth(url, tokens),
         {:ok, saml_response} <- parse_saml_response(response) do
      {:ok, insert_saml_response(process, saml_response)}
    end
  end

  defp parse_saml_response(%{body: body}) do
    with {:ok, document} <- parse_document(body) do
      fetch_saml_response(document)
    end
  end

  defp parse_document(body) do
    case Floki.parse_document(body) do
      {:ok, _document} = ok -> ok
      {:error, reason} -> {:error, Floki.ParseError.exception(reason)}
    end
  end

  defp fetch_saml_response(document) do
    case Floki.attribute(document, "input[name=SAMLResponse]", "value") do
      [saml_response] ->
        {:ok, saml_response}

      _wrong_data ->
        Logger.error("Modeus returns document, but without SAMLResponse:\n#{Floki.raw_html(document)}")
        {:error, :invalid_server_response}
    end
  end

  defp insert_saml_response(%AuthProcess{} = process, saml_response) do
    Map.put(process, :saml_response, saml_response)
  end

  defp get_id_token(process, username) do
    with {:ok, auth_url} <- get_auth_url(process),
         {:ok, auth_data} <- parse_auth_url(auth_url) do
      token =
        auth_data
        |> Map.put(:username, username)
        |> Token.new()

      {:ok, token}
    end
  end

  defp get_auth_url(%AuthProcess{saml_response: saml_response, relay_state: relay_state}) do
    body = %{
      "SAMLResponse" => saml_response,
      "RelayState" => relay_state
    }

    with {:ok, url} <- request_auth_link(body) do
      auth_with_url(url)
    end
  end

  defp request_auth_link(body) do
    with {:ok, response} <- Modeus.Client.request_auth_link(body) do
      case AuthHelpers.fetch_location(response) do
        {:ok, _auth_link} = ok ->
          ok

        :error ->
          "request_auth_link(...)"
          |> format_error(response)
          |> Logger.error()

          {:error, :invalid_server_response}
      end
    end
  end

  defp auth_with_url(url) do
    with {:ok, response} <- Modeus.Client.auth_with_url(url) do
      case AuthHelpers.fetch_location(response) do
        {:ok, _auth_link} = ok ->
          ok

        :error ->
          "auth_with_url(...)"
          |> format_error(response)
          |> Logger.error()

          {:error, :invalid_server_response}
      end
    end
  end

  defp parse_auth_url("#" <> data) do
    {:ok, URI.decode_query(data)}
  end

  defp parse_auth_url(<<_ignored::utf8, rest::binary>>) do
    parse_auth_url(rest)
  end

  defp parse_auth_url(_empty_string) do
    Logger.error("Modeus returns auth_url, but without commented query.")
    {:error, :invalid_server_response}
  end

  defp format_error(method, response), do: Utils.invalid_response_format_error("IStudent.Client", method, response)
end
