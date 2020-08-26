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
end
