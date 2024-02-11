defmodule UrfuApi.Modeus.Schedule.ScheduleData.EventOrganizer do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :event_id, String.t()
    field :links, map()
  end
end
