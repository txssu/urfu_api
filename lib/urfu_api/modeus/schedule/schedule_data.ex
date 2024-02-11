defmodule UrfuApi.Modeus.Schedule.ScheduleData do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  alias UrfuApi.Modeus.Schedule.ScheduleData.Building
  alias UrfuApi.Modeus.Schedule.ScheduleData.CourseUnitRealization
  alias UrfuApi.Modeus.Schedule.ScheduleData.CycleRealization
  alias UrfuApi.Modeus.Schedule.ScheduleData.Duration
  alias UrfuApi.Modeus.Schedule.ScheduleData.EducationalObject
  alias UrfuApi.Modeus.Schedule.ScheduleData.Event
  alias UrfuApi.Modeus.Schedule.ScheduleData.EventAttendance
  alias UrfuApi.Modeus.Schedule.ScheduleData.EventAttendee
  alias UrfuApi.Modeus.Schedule.ScheduleData.EventLocation
  alias UrfuApi.Modeus.Schedule.ScheduleData.EventOrganizer
  alias UrfuApi.Modeus.Schedule.ScheduleData.EventRoom
  alias UrfuApi.Modeus.Schedule.ScheduleData.LessonRealization
  alias UrfuApi.Modeus.Schedule.ScheduleData.LessonRealizationTeam
  alias UrfuApi.Modeus.Schedule.ScheduleData.Person
  alias UrfuApi.Modeus.Schedule.ScheduleData.PersonMidCheckResult
  alias UrfuApi.Modeus.Schedule.ScheduleData.PersonResult
  alias UrfuApi.Modeus.Schedule.ScheduleData.Room

  typedstruct enforce: true do
    field :buildings, [Building.t()]
    field :course_unit_realizations, [CourseUnitRealization.t()]
    field :cycle_realizations, [CycleRealization.t()]
    field :durations, [Duration.t()]
    field :educational_objects, [EducationalObject.t()]
    field :event_attendances, [EventAttendance.t()]
    field :event_attendees, [EventAttendee.t()]
    field :event_locations, [EventLocation.t()]
    field :event_organizers, [EventOrganizer.t()]
    field :event_rooms, [EventRoom.t()]
    field :events, [Event.t()]
    field :lesson_realization_teams, [LessonRealizationTeam.t()]
    field :lesson_realizations, [LessonRealization.t()]
    field :person_mid_check_results, [PersonMidCheckResult.t()]
    field :person_results, [PersonResult.t()]
    field :persons, [Person.t()]
    field :rooms, [Room.t()]
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) when is_map(fields) do
    fields
    |> normalize_keys()
    |> super()
    |> to_structs(Building, :buildings)
    |> to_structs(CourseUnitRealization, :course_unit_realizations)
    |> to_structs(CycleRealization, :cycle_realizations)
    |> to_structs(Duration, :durations)
    |> to_structs(EducationalObject, :educational_objects)
    # |> to_structs(EventAttendance, :event_attendances)
    |> to_structs(EventAttendee, :event_attendees)
    |> to_structs(EventLocation, :event_locations)
    |> to_structs(EventOrganizer, :event_organizers)
    |> to_structs(EventRoom, :event_rooms)
    |> to_structs(Event, :events)
    |> to_structs(LessonRealizationTeam, :lesson_realization_teams)
    |> to_structs(LessonRealization, :lesson_realizations)
    # |> to_structs(PersonMidCheckResult, :person_mid_check_result)
    # |> to_structs(PersonResult, :person_results)
    |> to_structs(Person, :persons)
    |> to_structs(Room, :rooms)
  end

  @spec fetch_by_link(map(), String.t(), t()) :: {:ok, map()} | :error
  def fetch_by_link(item, link_name, database) do
    link =
      item
      |> Map.fetch!(:links)
      |> Map.fetch(link_name)

    case link do
      :error -> :error
      {:ok, link} -> {:ok, exec_link(link, database)}
    end
  end

  @spec fetch_by_link!(map(), String.t(), t()) :: map()

  def fetch_by_link!(item, link_name, database) do
    item
    |> Map.fetch!(:links)
    |> Map.fetch!(link_name)
    |> exec_link(database)
  end

  @spec exec_link([atom() | binary()], map()) :: map()
  defp exec_link(link, collection)

  defp exec_link([], item) do
    item
  end

  defp exec_link([key | rest], map) when is_atom(key) and is_map(map) do
    exec_link(rest, Map.fetch!(map, key))
  end

  defp exec_link([id | rest], list) when is_binary(id) when is_list(list) do
    case rest do
      [] ->
        Enum.find(list, fn
          %{id: item_id} -> item_id == id
        end)

      [_self] ->
        Enum.find(list, fn
          %{event_id: event_id} -> event_id == id
        end)
    end
  end

  @spec normalize_keys(map()) :: map()
  defp normalize_keys(map) do
    for {key, value} <- map, into: %{} do
      {String.replace(key, "-", "_"), value}
    end
  end

  @spec to_structs(t(), module(), atom()) :: t()
  defp to_structs(database, struct_module, key) do
    Map.update!(database, key, fn
      nil -> []
      maps -> Enum.map(maps, &struct_module.new(to_links(&1)))
    end)
  end

  @spec to_links(map()) :: map()
  defp to_links(map) do
    links =
      for {key, %{"href" => "/" <> link}} <- normalize_keys(map["_links"]),
          key != "self",
          into: %{} do
        new_key = key_to_link(key)

        new_link =
          link
          |> String.split("/")
          |> List.insert_at(0, new_key)
          |> Enum.map(&maybe_to_atom/1)

        {key, new_link}
      end

    Map.put(map, :links, links)
  end

  @spec key_to_link(String.t()) :: String.t()
  defp key_to_link(field_name)
  defp key_to_link("location"), do: "event_locations"
  defp key_to_link("organizers"), do: "event_organizers"
  defp key_to_link("team"), do: "event_teams"
  defp key_to_link("event_rooms"), do: "event_rooms"
  defp key_to_link(key), do: key <> "s"

  @spec maybe_to_atom(String.t()) :: atom() | String.t()
  defp maybe_to_atom(str) do
    String.to_existing_atom(str)
  rescue
    ArgumentError -> str
  end
end
