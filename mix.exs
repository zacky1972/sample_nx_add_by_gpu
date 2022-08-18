defmodule SampleNxAddByGpu.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/zacky1972/sample_nx_add_by_gpu"
  @module_name "SampleNxAddByGpu"

  def project do
    [
      app: :sample_nx_add_by_gpu,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: @module_name,
      source_url: @source_url,
      docs: [
        main: @module_name,
        extras: ["README.md"]
      ],
      compilers: [:elixir_make] ++ Mix.compilers(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:nx, "~> 0.3"}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "LICENSE",
        "mix.exs",
        "README.md",
        "Makefile",
        "nif_src/*.c",
        "nif_src/*.h",
        "nif_src/cuda/*.h",
        "nif_src/cuda/*.cu",
        "nif_src/metal/*.h",
        "nif_src/metal/*.m",
        "nif_src/metal/*.metal"
      ]
    ]
  end
end
