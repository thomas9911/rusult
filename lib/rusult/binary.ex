defmodule Rusult.Binary do
  @moduledoc false

  def and_then(%Rusult{ok?: true, ok: ok}, func) do
    func.(ok)
  end

  def and_then(%Rusult{error?: true} = result, _) do
    result
  end

  def or_else(%Rusult{ok?: true} = result, _) do
    result
  end

  def or_else(%Rusult{error?: true, error: error}, func) do
    func.(error)
  end

  def if_err(%Rusult{ok?: true}, rhs) do
    rhs
  end

  def if_err(%Rusult{error?: true} = lhs, _) do
    lhs
  end

  def if_ok(%Rusult{ok?: true} = lhs, _) do
    lhs
  end

  def if_ok(%Rusult{error?: true}, %Rusult{} = rhs) do
    rhs
  end
end
