defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EventAttendee do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, String.t()
    field :links, map()
  end
end
