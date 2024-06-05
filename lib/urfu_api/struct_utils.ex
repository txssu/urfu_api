defmodule UrFUAPI.StructUtils do
  @moduledoc false

  @spec cast_field(map(), Map.key(), module()) :: map()
  def cast_field(map, field, module) when is_atom(module) do
    case Map.fetch!(map, field) do
      nil -> map
      value -> Map.put(map, field, module.new(value))
    end
  end

  @spec cast_many(map(), Map.key(), module()) :: map()
  def cast_many(map, field, module) when is_atom(module) do
    case Map.fetch!(map, field) do
      nil -> map
      value -> Map.put(map, field, Enum.map(value, &module.new/1))
    end
  end
end
