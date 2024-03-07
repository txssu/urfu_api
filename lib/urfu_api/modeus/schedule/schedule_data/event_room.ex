defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EventRoom do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, String.t()
    field :links, map()
  end
end
