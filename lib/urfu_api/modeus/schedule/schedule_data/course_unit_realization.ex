defmodule UrfuApi.Modeus.Schedule.ScheduleData.CourseUnitRealization do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, String.t()
    field :name, String.t()
    field :name_short, String.t()
    field :prototype_id, String.t()
    field :links, map()
  end
end
