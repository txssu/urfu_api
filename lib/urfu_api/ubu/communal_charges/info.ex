defmodule UrFUAPI.UBU.CommunalCharges.Info do
  @moduledoc false
  use TypedStruct
  use ExConstructor

  defmodule Charge do
    @moduledoc false
    use TypedStruct
    use ExConstructor

    typedstruct enforce: true do
      field :accrual, float()
      field :payment, float()
    end
  end

  typedstruct enforce: true do
    field :contract, String.t()
    field :debt, integer()
    field :deposit, integer()
    field :charges, [%{integer => %{integer => Charge.t()}}]
  end

  @spec new(ExConstructor.map_or_kwlist()) :: t()
  def new(fields) do
    fields
    |> super()
    |> parse_charges()
  end

  defp parse_charges(struct) do
    Map.update!(struct, :charges, fn charges ->
      convert(charges)
    end)
  end

  defp convert(charges) do
    Map.new(charges, fn %{"year" => value} = item ->
      months =
        item
        |> Map.fetch!("months")
        |> Stream.with_index(1)
        |> Stream.reject(fn {value, _index} -> is_nil(value) end)
        |> Map.new(fn {value, index} -> {index, Charge.new(value)} end)

      {value, months}
    end)
  end
end
