# Rusult

Result struct based on the Rust Result object.
  
\>\> Rust Result << -> Rusult


Implemented Rust Result stable functions (1.46):

- and ❌
- and_then ✔️ `and_then/2`
- err ❌
- expect ✔️ `expect!/2`
- expect_err ✔️ `expect_err!/2`
- is_err ✔️ `err?/0`
- is_ok ✔️ `ok?/0`
- iter ❌
- map ❌
- map_err ❌
- map_or ❌
- map_or_else ❌
- ok ❌
- or ❌
- or_else ✔️ `or_else/2`
- unwrap ✔️ `unwrap!/1`
- unwrap_err ✔️ `unwrap_err!/1`
- unwrap_or ✔️ `unwrap_or/2`
- unwrap_or_else ✔️ `unwrap_or_else/2`


## Examples

```elixir
iex> {:ok, 123} |> Rusult.from() |> Rusult.unwrap!()
123
```

```elixir
iex> {:ok, 1, 2}  
...> |> Rusult.from()
...> |> Rusult.and_then(fn {a, b} -> a + b end)
3
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

