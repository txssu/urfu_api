defmodule UrFUAPI.Modeus.Schedule do
  @moduledoc false
  alias UrFUAPI.Modeus.Auth.Token
  alias UrFUAPI.Modeus.Auth.TokenClaims
  alias UrFUAPI.Modeus.Client
  alias UrFUAPI.Modeus.Schedule.ScheduleData

  @spec get_schedule(Token.t(), DateTime.t(), DateTime.t()) :: ScheduleData.t()
  def get_schedule(%Token{claims: %TokenClaims{person_id: person_id}} = auth, after_time, before_time) do
    body = %{
      attendeePersonId: [person_id],
      timeMin: DateTime.to_iso8601(after_time),
      timeMax: DateTime.to_iso8601(before_time),
      size: 500
    }

    %{"_embedded" => database} = Client.request_schedule!("/calendar/events/search", auth, body)

    ScheduleData.new(database)
  end

  @spec fetch_by_link(map, String.t(), ScheduleData.t()) :: {:ok, map()} | :error
  defdelegate fetch_by_link(item, link_name, database), to: ScheduleData

  @spec fetch_by_link!(map, String.t(), ScheduleData.t()) :: map()
  defdelegate fetch_by_link!(item, link_name, database), to: ScheduleData
end
