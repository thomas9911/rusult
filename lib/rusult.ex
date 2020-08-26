defmodule Rusult do
  @moduledoc """
  Result struct based on the Rust Result object.

  \\>\\> Rust Result << -> Rusult
  """

  @type t :: %__MODULE__{error: any, ok: any, error?: boolean, ok?: boolean}

  @enforce_keys [:error?, :ok?]
  defstruct [:error, :ok, :error?, :ok?]

  @doc """
  Creates a :error


  ```
  iex> Rusult.error(:anything)
  %Rusult{error?: true, ok?: false, error: :anything}
  ```
  """
  @spec error(any) :: __MODULE__.t()
  def error(error) do
    %Rusult{error: error, error?: true, ok?: false}
  end

  @doc """
  Creates a :ok
  ```
  iex> Rusult.ok(:anything)
  %Rusult{error?: false, ok?: true, ok: :anything}
  ```
  """
  @spec ok(any) :: __MODULE__.t()
  def ok(ok \\ nil) do
    %Rusult{ok: ok, error?: false, ok?: true}
  end

  @doc """
  Create Rusult based on the input
  ```
  iex> Rusult.from(:anything)
  %Rusult{error?: false, ok?: true, ok: :anything}
  ```

  ```
  iex> Rusult.from(:ok)
  %Rusult{error?: false, ok?: true}
  ```

  ```
  iex> Rusult.from({:ok, "success"})
  %Rusult{error?: false, ok?: true, ok: "success"}
  ```

  ```
  iex> Rusult.from({:error, "failed"})
  %Rusult{error?: true, ok?: false, error: "failed"}
  ```
  """
  @spec from(any) :: __MODULE__.t()
  defdelegate from(any), to: Rusult.From

  @doc """
  Alias for from/1
  """
  def wrap(any), do: from(any)

  @doc """
  Convert a Rusult back to a elixir error tuple.

  opts:
  - flatten: boolean. If the result contains a tuple, it can be prepended with the :ok or :error. (true) or wrapped with :ok or :error (false) 

  ```
  iex> %{success: 3.1415} |> Rusult.ok() |> Rusult.to_tuple()
  {:ok, %{success: 3.1415}}
  ```

  ```
  iex> %{sad: 3} |> Rusult.error() |> Rusult.to_tuple()
  {:error, %{sad: 3}}
  ```

  flatten:
  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.to_tuple(flatten: true)
  {:error, 1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.to_tuple(flatten: false)
  {:ok, {1, 2, 3}}
  ```

  """
  @spec to_tuple(Rusult.t(), keyword) :: tuple
  defdelegate to_tuple(result, opts \\ []), to: Rusult.ToTuple

  @doc """
  Return the value if it is a :ok, Raises on :error.

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.unwrap!()
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.unwrap!()
  ** (RuntimeError) expected :ok, got {1, 2, 3}
  ```
  """
  @spec unwrap!(__MODULE__.t()) :: any
  def unwrap!(%__MODULE__{error: error} = result) do
    expect!(result, "expected :ok, got #{inspect(error)}")
  end

  @doc """
  Return the value if it is a :error, Raises on :ok.

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.unwrap_err!()
  ** (RuntimeError) expected :error, got {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.unwrap_err!()
  {1, 2, 3}
  ```
  """
  @spec unwrap_err!(__MODULE__.t()) :: any
  def unwrap_err!(%__MODULE__{ok: ok} = result) do
    expect_err!(result, "expected :error, got #{inspect(ok)}")
  end

  @doc """
  Return the value if it is a :ok, otherwise return other

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.unwrap_or(15)
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.unwrap_or(15)
  15
  ```
  """
  @spec unwrap_or(__MODULE__.t(), any) :: any
  def unwrap_or(%__MODULE__{ok?: true, ok: ok}, _) do
    ok
  end

  def unwrap_or(%__MODULE__{error?: true}, other) do
    other
  end

  @doc """
  Return the value if it is a :ok, otherwise calculate the given function with the error as its input.

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.unwrap_or_else(&elem(&1, 2))
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.unwrap_or_else(&elem(&1, 2))
  3
  ```

  This can also be used to calculate something dificult
  ```
  iex> get_tau = fn _ -> 
  ...>     # get something
  ...>     3.14159 * 2
  ...> end
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.unwrap_or_else(get_tau)
  6.28318
  ```
  """
  @spec unwrap_or_else(__MODULE__.t(), (any -> any)) :: any
  def unwrap_or_else(%__MODULE__{ok?: true, ok: ok}, _) do
    ok
  end

  def unwrap_or_else(%__MODULE__{error?: true, error: error}, func) do
    func.(error)
  end

  @doc """
  Return the value if it is a :ok, Raises on :error, with the supplied message.

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.expect!("bang!")
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.expect!("bang!")
  ** (RuntimeError) bang!
  ```
  """
  @spec expect!(__MODULE__.t(), binary) :: any
  def expect!(%__MODULE__{error?: true}, error_message) do
    raise RuntimeError, message: error_message
  end

  def expect!(%__MODULE__{ok?: true, ok: ok}, _) do
    ok
  end

  @doc """
  Return the value if it is a :error, Raises on :ok, with the supplied message.

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.expect_err!("bang!")
  ** (RuntimeError) bang!
  ```

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.expect_err!("bang!")
  {1, 2, 3}
  ```
  """
  @spec expect_err!(__MODULE__.t(), binary) :: any
  def expect_err!(%__MODULE__{error?: true, error: error}, _) do
    error
  end

  def expect_err!(%__MODULE__{ok?: true}, error_message) do
    raise RuntimeError, message: error_message
  end

  @doc """

  ```
  iex> 5
  ...> |> Rusult.ok()
  ...> |> Rusult.and_then(fn x -> Rusult.ok(x * 2) end)
  ...> |> Rusult.and_then(fn x -> Rusult.ok(x + 1) end)
  Rusult.ok(11)

  iex> 5
  ...> |> Rusult.ok()
  ...> |> Rusult.and_then(fn x -> Rusult.ok(x * 2) end)
  ...> |> Rusult.and_then(fn _x -> Rusult.error("failed") end)
  Rusult.error("failed")

  iex> 5
  ...> |> Rusult.ok()
  ...> |> Rusult.and_then(fn _x -> Rusult.error("failed") end)
  ...> |> Rusult.and_then(fn x -> Rusult.ok(x + 1) end)
  Rusult.error("failed")

  iex> 5
  ...> |> Rusult.ok()
  ...> |> Rusult.and_then(fn _x -> Rusult.error("failed") end)
  ...> |> Rusult.and_then(fn _x -> Rusult.error("still failed") end)
  Rusult.error("failed")
  ```
  """
  @spec and_then(__MODULE__.t(), (any -> __MODULE__.t())) :: __MODULE__.t()
  def and_then(%__MODULE__{ok?: true, ok: ok}, func) do
    func.(ok)
  end

  def and_then(%__MODULE__{error?: true} = result, _) do
    result
  end

  @doc """

  ```
  iex> 5
  ...> |> Rusult.ok()
  ...> |> Rusult.or_else(fn x -> Rusult.ok(x * 2) end)
  ...> |> Rusult.or_else(fn x -> Rusult.ok(x + 1) end)
  Rusult.ok(5)

  iex> 5
  ...> |> Rusult.error()
  ...> |> Rusult.or_else(fn x -> Rusult.ok(x * 2) end)
  ...> |> Rusult.or_else(fn _x -> Rusult.error("failed") end)
  Rusult.ok(10)

  iex> 5
  ...> |> Rusult.ok()
  ...> |> Rusult.or_else(fn _x -> Rusult.error("failed") end)
  ...> |> Rusult.or_else(fn x -> Rusult.ok(x + 1) end)
  Rusult.ok(5)

  iex> 5
  ...> |> Rusult.error()
  ...> |> Rusult.or_else(fn _x -> Rusult.error("failed") end)
  ...> |> Rusult.or_else(fn _x -> Rusult.error("still failed") end)
  Rusult.error("still failed")
  ```
  """
  @spec and_then(__MODULE__.t(), (any -> __MODULE__.t())) :: __MODULE__.t()
  def or_else(%__MODULE__{ok?: true} = result, _) do
    result
  end

  def or_else(%__MODULE__{error?: true, error: error}, func) do
    func.(error)
  end
end
