defmodule UrfuApi.Modeus.Schedule.ScheduleData.PersonMidCheckResult do
  # TODO
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :links, map()
  end
end
