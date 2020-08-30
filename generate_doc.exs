{:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} = Code.fetch_docs(Rusult)

IO.puts("# Rusult\n")

IO.puts("![Hex.pm](https://img.shields.io/hexpm/v/rusult)")
IO.puts("![Hex.pm](https://img.shields.io/hexpm/l/rusult)")
IO.puts("![Hex.pm](https://img.shields.io/hexpm/dt/rusult)")

IO.puts("""
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
""")

module_doc |> IO.puts()