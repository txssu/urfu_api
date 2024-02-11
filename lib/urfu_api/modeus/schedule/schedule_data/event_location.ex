defmodule UrfuApi.Modeus.Schedule.ScheduleData.EventLocation do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :event_id, String.t()
    field :custom_location, String.t() | nil
    field :links, map()
  end
end
