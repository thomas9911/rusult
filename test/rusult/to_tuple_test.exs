defmodule Rusult.ToTupleTest do
  use ExUnit.Case

  test "{:ok, []}" do
    assert {:ok, []} == [] |> Rusult.ok() |> Rusult.to_tuple()
  end

  test "{:ok, nil}" do
    assert {:ok, nil} == Rusult.ok() |> Rusult.to_tuple()
  end

  test "{:ok, 1, 2}" do
    assert {:ok, 1, 2} == {1, 2} |> Rusult.ok() |> Rusult.to_tuple()
  end

  test "{:ok, {1, 2}}" do
    assert {:ok, {1, 2}} == {1, 2} |> Rusult.ok() |> Rusult.to_tuple(flatten: false)
  end
end
