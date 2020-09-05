defmodule Rusult.MixProject do
  use Mix.Project

  def project do
    [
      app: :rusult,
      version: "1.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      name: "Rusult",
      deps: deps(),
      package: package(),
      description: "Result struct based on the Rust Result object.",
      source_url: "https://github.com/thomas9911/rusult",
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
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:mix_readme, "~> 0.1.0", runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Unlicense"],
      links: %{"GitHub" => "https://github.com/thomas9911/rusult"}
    ]
  end
end
