defmodule Rusult.MixProject do
  use Mix.Project

  def project do
    [
      app: :rusult,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Rusult",
      source_url: "https://github.com/thomas9911/rusult",
      docs: [
        main: "Rusult",
        extra_section: []
        # extras: ["README.md"]
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
