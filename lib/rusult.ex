defmodule Rusult do
  @moduledoc """
  Result struct based on the Rust Result object.
    
  \\>\\> Rust Result << -> Rusult


  Implemented Rust Result stable functions (1.46):

  - and ✔️ `if_err/2`
  - and_then ✔️ `and_then/2`
  - err ✔️ `error_or_nil/1`
  - expect ✔️ `expect!/2`
  - expect_err ✔️ `expect_err!/2`
  - is_err ✔️ `error?/0`
  - is_ok ✔️ `ok?/0`
  - iter ✔️ `ok_or_nil/1`
  - map ✔️ `map/2`
  - map_err ✔️ `map_err/2`
  - map_or ✔️ `map_or/3`
  - map_or_else ✔️ `map_or_else/3`
  - ok ✔️ `ok_or_nil/1`
  - or ✔️ `if_ok/2`
  - or_else ✔️ `or_else/2`
  - unwrap ✔️ `unwrap!/1`
  - unwrap_err ✔️ `unwrap_err!/1`
  - unwrap_or ✔️ `unwrap_or/2`
  - unwrap_or_else ✔️ `unwrap_or_else/2`

  Extra functions:

  - `map_err_or/3`
  - `unwrap_err_or/2`
  - `unwrap_err_or_else/2`
  - `wrap/1`

  Implemented Rust Result unstable functions (1.46):

  - contains ❌
  - contains_err ❌
  - flatten ❌
  - into_ok ❌

  ## Examples

  ```elixir
  iex> {:ok, 123} |> Rusult.from() |> Rusult.unwrap!()
  123
  ```

  ```elixir
  iex> {:ok, 1, 2}  
  ...> |> Rusult.from()
  ...> |> Rusult.and_then(fn {a, b} -> Rusult.ok(a + b) end)
  ...> |> Rusult.to_tuple()
  {:ok, 3}
  ```

  ```elixir
  iex> defmodule MyModule do
  ...>     def transform_value(%Rusult{ok?: true}) do
  ...>         {:ok, 123}
  ...>     end
  ...>     def transform_value(%Rusult{error?: true}) do
  ...>         {:error, :found_error}
  ...>     end
  ...> end
  ...>
  ...> "ERROR!"
  ...> |> Rusult.error()
  ...> |> MyModule.transform_value()
  ...> |> Rusult.from()
  ...> |> Rusult.expect_err!("this is ok?")
  :found_error
  ```
  """

  @type t :: %__MODULE__{error: any, ok: any, error?: boolean, ok?: boolean}
  @type rusult_struct :: %{error: any, ok: any, error?: boolean, ok?: boolean, __struct__: atom}
  @type function_out :: any
  @type default :: any

  @enforce_keys [:error?, :ok?]
  defstruct [:error, :ok, :error?, :ok?]

  @doc """
  Creates a :error

  ```
  iex> Rusult.error(:anything)
  %Rusult{error?: true, ok?: false, error: :anything}
  ```
  """
  @spec error(any) :: rusult_struct
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
  @spec ok(any) :: rusult_struct
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
  @spec from(any) :: rusult_struct
  defdelegate from(any), to: Rusult.From

  @doc """
  Alias for `from/1`

  ```
  iex> Rusult.wrap(:anything)
  %Rusult{error?: false, ok?: true, ok: :anything}
  ```
  """
  defdelegate wrap(any), to: Rusult.From, as: :from

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
  @spec unwrap!(rusult_struct) :: any
  def unwrap!(%_{error: error} = result) do
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
  @spec unwrap_err!(rusult_struct) :: any
  def unwrap_err!(%_{ok: ok} = result) do
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
  @spec unwrap_or(rusult_struct, any) :: any
  def unwrap_or(%_{ok?: true, ok: ok}, _) do
    ok
  end

  def unwrap_or(%_{error?: true}, other) do
    other
  end

  @doc """
  Return the value if it is a :error, otherwise return other

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.unwrap_err_or(15)
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.unwrap_err_or(15)
  15
  ```
  """
  @spec unwrap_err_or(rusult_struct, any) :: any
  def unwrap_err_or(%_{error?: true, error: error}, _) do
    error
  end

  def unwrap_err_or(%_{ok?: true}, other) do
    other
  end

  @doc """
  Return the value if it is a :ok, otherwise returns nil

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.ok_or_nil()
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.ok_or_nil()
  nil
  ```
  """
  def ok_or_nil(%_{} = result) do
    unwrap_or(result, nil)
  end

  @doc """
  Return the value if it is a :error, otherwise returns nil

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.error_or_nil()
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.error_or_nil()
  nil
  ```
  """
  def error_or_nil(%_{} = result) do
    unwrap_err_or(result, nil)
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
  @spec unwrap_or_else(rusult_struct, (any -> any)) :: any
  def unwrap_or_else(%_{ok?: true, ok: ok}, _) do
    ok
  end

  def unwrap_or_else(%_{error?: true, error: error}, func) do
    func.(error)
  end

  @doc """
  Return the value if it is a :error, otherwise calculate the given function with the ok as its input.

  ```
  iex> {1, 2, 3} |> Rusult.error() |> Rusult.unwrap_err_or_else(&elem(&1, 2))
  {1, 2, 3}
  ```

  ```
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.unwrap_err_or_else(&elem(&1, 2))
  3
  ```

  This can also be used to calculate something dificult
  ```
  iex> get_tau = fn _ -> 
  ...>     # get something
  ...>     3.14159 * 2
  ...> end
  iex> {1, 2, 3} |> Rusult.ok() |> Rusult.unwrap_err_or_else(get_tau)
  6.28318
  ```
  """
  @spec unwrap_err_or_else(rusult_struct, (any -> any)) :: any
  def unwrap_err_or_else(%_{error?: true, error: error}, _) do
    error
  end

  def unwrap_err_or_else(%_{ok?: true, ok: ok}, func) do
    func.(ok)
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
  @spec expect!(rusult_struct, binary) :: any
  def expect!(%_{error?: true}, error_message) do
    raise RuntimeError, message: error_message
  end

  def expect!(%_{ok?: true, ok: ok}, _) do
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
  @spec expect_err!(rusult_struct, binary) :: any
  def expect_err!(%_{error?: true, error: error}, _) do
    error
  end

  def expect_err!(%_{ok?: true}, error_message) do
    raise RuntimeError, message: error_message
  end

  @doc """
  Applies the function if the Rusult is :ok

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

  like `or_else/2` or `map/2`
  """
  @spec and_then(rusult_struct, (any -> function_out)) :: function_out | rusult_struct
  defdelegate and_then(result, func), to: Rusult.Binary

  @doc """
  Applies the function if the Rusult is :error

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
  like `and_then/2` or `map_err/2`
  """
  @spec or_else(rusult_struct, (any -> function_out)) :: function_out | rusult_struct
  defdelegate or_else(result, func), to: Rusult.Binary

  @doc """
  Applies the function if the Rusult is :ok and wraps the output in an :ok

  Because in Elixir you can overload functions `map/3` is an alias for `map_or/3`

  ```
  iex> [1, 2, 3, 4]
  ...> |> Rusult.ok()
  ...> |> Rusult.map(fn x -> Enum.sum(x) end)
  ...> |> Rusult.map(fn x -> x + 5 end)
  Rusult.ok(15)

  iex> [1, 2, 3, 4]
  ...> |> Rusult.error()
  ...> |> Rusult.map(fn x -> Enum.sum(x) end)
  ...> |> Rusult.map(fn x -> x + 5 end)
  Rusult.error([1, 2, 3, 4])
  ``` 
  """
  @spec map(rusult_struct, (any -> any)) :: rusult_struct
  def map(%_{ok?: true, ok: ok}, func) do
    Rusult.ok(func.(ok))
  end

  def map(%_{error?: true} = error, _) do
    error
  end

  @spec map(rusult_struct, default, (any -> function_out)) :: function_out | default
  def map(%_{} = result, default, func) do
    map_or(result, default, func)
  end

  @doc """
  Applies the function if the Rusult is :error and wraps the output in an :error

  ```
  iex> [1, 2, 3, 4]
  ...> |> Rusult.error()
  ...> |> Rusult.map_err(fn x -> Enum.sum(x) end)
  ...> |> Rusult.map_err(fn x -> x + 5 end)
  Rusult.error(15)

  iex> [1, 2, 3, 4]
  ...> |> Rusult.ok()
  ...> |> Rusult.map_err(fn x -> Enum.sum(x) end)
  ...> |> Rusult.map_err(fn x -> x + 5 end)
  Rusult.ok([1, 2, 3, 4])
  ``` 
  """
  @spec map_err(rusult_struct, (any -> any)) :: rusult_struct
  def map_err(%_{ok?: true} = result, _) do
    result
  end

  def map_err(%_{error?: true, error: error}, func) do
    Rusult.error(func.(error))
  end

  @doc """
  Applies the function if the Rusult is :ok and returns the output of the function. If it is an :error return the default.

  ```
  iex> [1, 2, 3, 4]
  ...> |> Rusult.ok()
  ...> |> Rusult.map_or(120, fn x -> Enum.sum(x) end)
  10

  iex> [1, 2, 3, 4]
  ...> |> Rusult.error()
  ...> |> Rusult.map_or(120, fn x -> Enum.sum(x) end)
  120
  ``` 
  """
  @spec map_or(rusult_struct, default, (any -> function_out)) :: function_out | default
  def map_or(%_{} = result, default, func) do
    result |> map(func) |> unwrap_or(default)
  end

  @doc """
  Applies the function if the Rusult is :error and returns the output of the function. If it is an :ok return the default.

  ```
  iex> [1, 2, 3, 4]
  ...> |> Rusult.error()
  ...> |> Rusult.map_err_or(120, fn x -> Enum.sum(x) end)
  10

  iex> [1, 2, 3, 4]
  ...> |> Rusult.ok()
  ...> |> Rusult.map_err_or(120, fn x -> Enum.sum(x) end)
  120
  ``` 
  """
  @spec map_err_or(rusult_struct, default, (any -> function_out)) :: function_out | default
  def map_err_or(%_{} = result, default, func) do
    result |> map_err(func) |> unwrap_err_or(default)
  end

  @doc """
  Applies the first function if the Rusult is :error and returns the output of the function. Applies the second function if the Rusult is :ok and returns the output of the function.

  ```
  iex> [1, 2, 3, 4]
  ...> |> Rusult.ok()
  ...> |> Rusult.map_or_else(
  ...>     fn e -> Enum.concat(e, [15, 20]) end, 
  ...>     fn x -> Enum.sum(x) end
  ...> )
  10

  iex> [1, 2, 3, 4]
  ...> |> Rusult.error()
  ...> |> Rusult.map_or_else(
  ...>     fn e -> Enum.concat(e, [15, 20]) end, 
  ...>     fn x -> Enum.sum(x) end
  ...> )
  [1, 2, 3, 4, 15, 20]
  ``` 
  """
  @spec map_or_else(rusult_struct, (any -> default), (any -> function_out)) ::
          function_out | default
  def map_or_else(%_{ok?: true, ok: ok}, _, ok_function) do
    ok_function.(ok)
  end

  def map_or_else(%_{error?: true, error: error}, error_function, _) do
    error_function.(error)
  end

  @doc """
  If :ok returns the first argument otherwise return the second argument

  ```
  iex> a = Rusult.ok([1, 2, 3, 4])
  iex> b = Rusult.ok(:something)
  iex> Rusult.if_ok(a, b)
  Rusult.ok([1, 2, 3, 4])

  iex> a = Rusult.error(:error)
  iex> b = Rusult.ok(:something)
  iex> Rusult.if_ok(a, b)
  Rusult.ok(:something)
  ```

  It is similar to using just an if statement like:
  ```
  iex> a = Rusult.ok([1, 2, 3, 4])
  iex> b = Rusult.ok(:something)
  iex> if a.ok? do
  ...>     a
  ...> else
  ...>     b
  ...> end
  Rusult.ok([1, 2, 3, 4])
  ```

  """
  @spec if_ok(rusult_struct, rusult_struct | any) :: rusult_struct | any
  defdelegate if_ok(lhs, rhs), to: Rusult.Binary

  @doc """
  If :error returns the first argument otherwise return the second argument

  ```
  iex> a = Rusult.ok([1, 2, 3, 4])
  iex> b = Rusult.ok(:something)
  iex> Rusult.if_err(a, b)
  Rusult.ok(:something)

  iex> a = Rusult.error(:error)
  iex> b = Rusult.ok(:something)
  iex> Rusult.if_err(a, b)
  Rusult.error(:error)
  ```

  It is similar to using just an if statement like:
  ```
  iex> a = Rusult.error(:error)
  iex> b = Rusult.ok(:something)
  iex> if a.error? do
  ...>     a
  ...> else
  ...>     b
  ...> end
  Rusult.error(:error)
  ```

  """
  @spec if_err(rusult_struct, rusult_struct | any) :: rusult_struct | any
  defdelegate if_err(lhs, rhs), to: Rusult.Binary
end
