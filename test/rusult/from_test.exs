defmodule Rusult.FromTest do
  use ExUnit.Case

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
