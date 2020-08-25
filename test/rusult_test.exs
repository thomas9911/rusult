defmodule RusultTest do
  use ExUnit.Case
  doctest Rusult

  describe "ok" do
    setup do
      %{result: Rusult.ok("success")}
    end

    test "ok?", %{result: result} do
      assert result.ok?
    end

    test "error?", %{result: result} do
      refute result.error?
    end

    test "success", %{result: result} do
      assert "success" == result.ok
    end

    test "error", %{result: result} do
      assert is_nil(result.error)
    end
  end

  describe "error" do
    setup do
      %{result: Rusult.error("failed")}
    end

    test "ok?", %{result: result} do
      refute result.ok?
    end

    test "error?", %{result: result} do
      assert result.error?
    end

    test "failed", %{result: result} do
      assert "failed" == result.error
    end

    test "ok", %{result: result} do
      assert is_nil(result.ok)
    end
  end

  describe "from" do
    test "{:ok, nil}" do
      assert Rusult.from({:ok, nil}).ok?
      refute Rusult.from({:ok, nil}).error?
    end

    test "{:error, nil}" do
      refute Rusult.from({:error, nil}).ok?
      assert Rusult.from({:error, nil}).error?
    end

    test ":ok" do
      assert Rusult.from(:ok).ok?
      refute Rusult.from(:ok).error?
    end

    test "{:ok, \"test\"}" do
      assert Rusult.from({:ok, "test"}).ok?
      assert "test" == Rusult.from({:ok, "test"}).ok
      refute Rusult.from({:ok, "test"}).error?
      refute Rusult.from({:ok, "test"}).error
    end

    test "{:error, \"test\"}" do
      refute Rusult.from({:error, "test"}).ok?
      refute Rusult.from({:error, "test"}).ok
      assert Rusult.from({:error, "test"}).error?
      assert "test" == Rusult.from({:error, "test"}).error
    end

    test "{:ok, \"test\", \"test\"}" do
      result = Rusult.from({:ok, "test", "test"})
      assert result.ok?
      assert {"test", "test"} == result.ok
      refute result.error?
      refute result.error
    end

    test "{:error, \"test\", \"test\"}" do
      result = Rusult.from({:error, "test", "test"})
      refute result.ok?
      refute result.ok
      assert result.error?
      assert {"test", "test"} == result.error
    end
  end

  describe "to_tuple" do
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
end
