# Rusult

![Hex.pm](https://img.shields.io/hexpm/v/rusult)
![Hex.pm](https://img.shields.io/hexpm/l/rusult)
![Hex.pm](https://img.shields.io/hexpm/dt/rusult)
## Installation

The package can be installed by adding `rusult` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rusult, "~> 1.0.0"}
  ]
end
```

## Description

Result struct based on the Rust Result object.
  
\>\> Rust Result << -> Rusult


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

