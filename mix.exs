defmodule Rusult.MixProject do
  use Mix.Project

  def project do
    [
      app: :rusult,
      version: "1.0.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      licenses: "Unlicense",
      description: "Result struct based on the Rust Result object.",
      source_url: "https://github.com/thomas9911/rusult",
      links: %{"GitHub" => "https://github.com/thomas9911/rusult"},
      docs: [
        main: "Rusult",
        extra_section: []
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end
end
