defmodule UrfuApi.Utils do
  @moduledoc false
  @spec invalid_response_format_error(String.t(), String.t(), term()) :: String.t()
  def invalid_response_format_error(client, method, response) do
    response_str = inspect(response)
    "#{client}.#{method} returns wrong format:\n#{response_str}"
  end
end
