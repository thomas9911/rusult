defmodule Rusult.ToTuple do
  @moduledoc false

  @default_to_tuple_opts [flatten: true]

  def to_tuple(%Rusult{} = result, opts \\ []) do
    opts = Keyword.merge(@default_to_tuple_opts, opts)
    do_to_tuple(result, opts)
  end

  defp do_to_tuple(%Rusult{ok?: true, ok: ok}, flatten: true) when is_tuple(ok) do
    Tuple.insert_at(ok, 0, :ok)
  end

  defp do_to_tuple(%Rusult{ok?: true, ok: ok}, flatten: false) when is_tuple(ok) do
    {:ok, ok}
  end

  defp do_to_tuple(%Rusult{error?: true, error: error}, flatten: true) when is_tuple(error) do
    Tuple.insert_at(error, 0, :error)
  end

  defp do_to_tuple(%Rusult{error?: true, error: error}, flatten: false) when is_tuple(error) do
    {:error, error}
  end

  defp do_to_tuple(%Rusult{ok?: true, ok: ok}, _) do
    {:ok, ok}
  end

  defp do_to_tuple(%Rusult{error?: true, error: error}, _) do
    {:error, error}
  end
end
