defmodule UrfuApi.Modeus.Schedule.ScheduleData.PersonResult do
  # TODO
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :links, map()
  end
end
