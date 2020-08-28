{:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} = Code.fetch_docs(Rusult)

IO.puts("# Rusult\n")

module_doc |> IO.puts()