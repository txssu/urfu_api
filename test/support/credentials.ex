defmodule UrFUAPI.Credentials do
  @moduledoc false
  def fetch_from_env do
    username = System.fetch_env!("URFU_USERNAME")
    password = System.fetch_env!("URFU_PASSWORD")

    %{username: username, password: password}
  end
end
