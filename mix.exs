defmodule SpandexQuantum.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :spandex_quantum,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      dialyzer: [
        plt_add_deps: :app_tree,
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:ex_unit, :mix],
        ignore_warnings: "dialyzer.ignore_warnings"
      ],
      description: "Handles the passing of Telemetry calls from Quantum to Spandex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:e2e), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:test, :dev], runtime: false},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:spandex, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      name: "spandex_quantum",
      maintainers: ["Marc Smith"],
      files: ["lib", "mix.exs", "README*"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/smartrent/spandex_quantum"}
    ]
  end
end
