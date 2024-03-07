defmodule UrFUAPI.Modeus.Schedule.ScheduleData.EducationalObject do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  typedstruct enforce: true do
    field :id, String.t()
    field :external_object_id, String.t()
    field :type_code, String.t()
    field :links, map()
  end
end
