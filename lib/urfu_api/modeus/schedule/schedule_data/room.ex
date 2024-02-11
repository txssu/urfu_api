defmodule UrfuApi.Modeus.Schedule.ScheduleData.Room do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  alias UrfuApi.Modeus.Schedule.ScheduleData.Building

  typedstruct enforce: true do
    field :id, String.t()
    field :building, Building.t()
    field :deleted_at_utc, DateTime.t() | nil
    field :name, String.t()
    field :name_short, String.t()
    field :projector_available, boolean()
    field :total_capacity, integer()
    field :working_capacity, integer()
    field :links, map()
  end
end
