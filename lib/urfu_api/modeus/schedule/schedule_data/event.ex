defmodule UrFUAPI.Modeus.Schedule.ScheduleData.Event do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  defmodule HoldingStatus do
    @moduledoc false
    use TypedStruct
    use ExConstructor

    typedstruct enforce: true do
      field :aud_modified_at, any()
      field :aud_modified_by, any()
      field :aud_modified_by_system, any()
      field :id, String.t()
      field :name, String.t()
    end
  end

  typedstruct enforce: true do
    field :description, String.t() | nil

    field :end, DateTime.t()
    field :ends_at, DateTime.t()
    field :ends_at_local, DateTime.t()

    field :format_id, String.t() | nil
    field :holding_status, HoldingStatus.t()
    field :id, String.t()
    field :lesson_template_id, String.t()
    field :name, String.t()
    field :name_short, String.t()

    field :start, DateTime.t()
    field :starts_at, DateTime.t()
    field :starts_at_local, DateTime.t()

    field :type_id, String.t()
    field :user_role_ids, [String.t()]

    field :links, map()
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> super()
    |> put_datetime(:end, false)
    |> put_datetime(:ends_at)
    |> put_datetime(:ends_at_local)
    |> put_datetime(:start, false)
    |> put_datetime(:starts_at)
    |> put_datetime(:starts_at_local)
    |> insert_holding_status()
  end

  @spec insert_holding_status(t()) :: t()
  defp insert_holding_status(struct) do
    Map.update!(struct, :holding_status, &HoldingStatus.new/1)
  end

  @spec put_datetime(t(), atom(), boolean()) :: t()
  defp put_datetime(struct, key, utc? \\ true) do
    if utc? do
      Map.update!(struct, key, &to_datetime(&1 <> "Z"))
    else
      %{links: %{"time_zone" => [_ | rest]}} = struct

      time_zone = Enum.join(rest, "/")

      Map.update!(struct, key, &to_datetime(&1, time_zone))
    end
  end

  @spec to_datetime(String.t(), String.t()) :: DateTime.t()
  defp to_datetime(str, time_zone \\ "Etc/UTC") do
    {:ok, date, _offset} = DateTime.from_iso8601(str)
    {:ok, date_with_zone} = DateTime.shift_zone(date, time_zone)

    date_with_zone
  end
end
