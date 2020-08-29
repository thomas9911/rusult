defmodule Rusult.From do
  @moduledoc false

  def from(%Rusult{} = result) do
    result
  end

  def from({:error, error}) do
    Rusult.error(error)
  end

  def from({:ok, ok}) do
    Rusult.ok(ok)
  end

  def from(tuple) when elem(tuple, 0) == :ok do
    Rusult.ok(Tuple.delete_at(tuple, 0))
  end

  def from(tuple) when elem(tuple, 0) == :error do
    Rusult.error(Tuple.delete_at(tuple, 0))
  end

  def from(:ok) do
    Rusult.ok()
  end

  def from(other) do
    Rusult.ok(other)
  end
end
