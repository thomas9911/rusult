%{
  app: :rusult,
  description: "Result struct based on the Rust Result object.",
  elixir: "~> 1.9",
  module: "Rusult",
  module_name: "Rusult",
  name: "Rusult",
  package: [
    licenses: ["Unlicense"],
    links: %{"GitHub" => "https://github.com/thomas9911/rusult"}
  ],
  template_path: "./readme.eex",
  version: "1.0.0"
}
# Rusult

[![Hex.pm](https://img.shields.io/hexpm/v/rusult)](https://hex.pm/packages/rusult)
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

Use your own Rusult module.

```elixir
iex> defmodule MyRusult do
...>     @type t :: %__MODULE__{error: binary, ok: map, error?: boolean, ok?: boolean}
...>     @enforce_keys [:error?, :ok?]
...>     defstruct [:error, :ok, :error?, :ok?] 
...>
...>     def from(%Rusult{error: _error, ok: ok, error?: false, ok?: true}) do
...>        from(ok)
...>     end
...>     
...>     def from(%Rusult{error: error, ok: _ok, error?: true, ok?: false}) do
...>        %MyRusult{ok?: false, error?: true, error: error}
...>     end
...>     
...>     def from(data) when is_map(data) do
...>        %MyRusult{ok?: true, error?: false, ok: data}
...>     end
...>
...>     def from(_data) do
...>        %MyRusult{ok?: false, error?: true, error: "invalid data"}
...>     end
...> end
iex> %{data: [1,2,3,4]}
...> |> MyRusult.from()
...> |> Rusult.map(fn %{data: data} -> %{data: Enum.sum(data)} end)
...> |> MyRusult.from()
...> |> Map.from_struct()
%{ok?: true, error?: false, ok: %{data: 10}, error: nil}
iex> "testing"
...> |> MyRusult.from()
...> |> Rusult.map(fn %{data: data} -> Enum.sum(data) end)
...> |>IO.inspect()
...> |> MyRusult.from()
%{ok?: false, error?: true, error: "invalid data"}
```


