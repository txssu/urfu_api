defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EventAttendance do
  # TODO
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :links, map()
  end
end
