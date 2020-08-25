defmodule Rusult do
  @moduledoc """
  Result struct based on the Rust Result object.
  
  >> Rust Result << -> Rusult
  """

  @type t :: %__MODULE__{error: any, ok: any, error?: boolean, ok?: boolean}

  @enforce_keys [:error?, :ok?]
  defstruct [:error, :ok, :error?, :ok?]

  @default_to_tuple_opts [flatten: true]

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
  def from({:error, error}) do
    error(error)
  end

  def from({:ok, ok}) do
    ok(ok)
  end

  def from(tuple) when elem(tuple, 0) == :ok do
    ok(Tuple.delete_at(tuple, 0))
  end

  def from(tuple) when elem(tuple, 0) == :error do
    error(Tuple.delete_at(tuple, 0))
  end

  def from(:ok) do
    ok()
  end

  def from(other) do
    ok(other)
  end

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
  @spec to_tuple(__MODULE__.t()) :: tuple
  @spec to_tuple(__MODULE__.t(), keyword) :: tuple
  def to_tuple(%__MODULE__{} = result, opts \\ []) do
    opts = Keyword.merge(@default_to_tuple_opts, opts)
    do_to_tuple(result, opts)
  end

  defp do_to_tuple(%__MODULE__{ok?: true, ok: ok}, flatten: true) when is_tuple(ok) do
    Tuple.insert_at(ok, 0, :ok)
  end

  defp do_to_tuple(%__MODULE__{ok?: true, ok: ok}, flatten: false) when is_tuple(ok) do
    {:ok, ok}
  end

  defp do_to_tuple(%__MODULE__{error?: true, error: error}, flatten: true) when is_tuple(error) do
    Tuple.insert_at(error, 0, :error)
  end

  defp do_to_tuple(%__MODULE__{error?: true, error: error}, flatten: false) when is_tuple(error) do
    {:error, error}
  end

  defp do_to_tuple(%__MODULE__{ok?: true, ok: ok}, _) do
    {:ok, ok}
  end

  defp do_to_tuple(%__MODULE__{error?: true, error: error}, _) do
    {:error, error}
  end

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
  def unwrap!(%__MODULE__{error?: true, error: error}) do
    raise RuntimeError, message: "expected :ok, got #{inspect(error)}"
  end

  def unwrap!(%__MODULE__{ok?: true, ok: ok}) do
    ok
  end
end
