defmodule LineBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_bot,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LineBot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.7.0"},
      {:jiffy, "~> 1.0"},
      {:ex_trends, "~> 0.1.0"}
    ]
  end
end
