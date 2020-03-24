defmodule Lab1.MixProject do
  use Mix.Project

  def project do
    [
      app: :lab1,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Lab1.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:eventsource_ex, "~> 0.0.2"},
      {:poison, "~> 3.0"}
    ]
  end
end
