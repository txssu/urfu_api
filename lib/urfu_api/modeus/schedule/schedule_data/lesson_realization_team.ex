defmodule UrFUAPI.Modeus.Schedule.ScheduleData.LessonRealizationTeam do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, String.t()
    field :name, String.t()
    field :links, map()
  end
end
