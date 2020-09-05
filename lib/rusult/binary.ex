defmodule Rusult.Binary do
  @moduledoc false

  def and_then(%_{ok?: true, ok: ok}, func) do
    func.(ok)
  end

  def and_then(%_{error?: true} = result, _) do
    result
  end

  def or_else(%_{ok?: true} = result, _) do
    result
  end

  def or_else(%_{error?: true, error: error}, func) do
    func.(error)
  end

  def if_err(%_{ok?: true}, rhs) do
    rhs
  end

  def if_err(%_{error?: true} = lhs, _) do
    lhs
  end

  def if_ok(%_{ok?: true} = lhs, _) do
    lhs
  end

  def if_ok(%_{error?: true}, %_{} = rhs) do
    rhs
  end
end
