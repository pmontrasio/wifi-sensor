defmodule Sensor.Mixfile do
  use Mix.Project

  def project do
    [app: :sensor,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     erlc_paths: ["erlang"],
     #escript: escript,
     default_task: "sensor",
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Can't do this because of https://github.com/elixir-lang/elixir/issues/5444
  # If it worked then: mix escript.build; ./sensor wlan1
  #def escript do
  #  [main_module: Main]
  #end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
     {:wierl, github: "msantos/wierl"},
     {:epcap, github: "msantos/epcap"},
     {:httpoison, "~> 0.10.0"}
    ]
  end
end
