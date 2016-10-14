defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi"

  def project do
    [app: :fw,
     version: "0.0.1",
     elixir: "~> 1.3",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.1.4"],
     deps_path: "../../deps/#{@target}",
     build_path: "../../_build/#{@target}",
     lockfile: "../../mix.lock",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(Mix.env),
     deps: deps ++ system(@target, Mix.env)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Fw, []},
     applications: applications(Mix.env)]
  end
  defp applications(:prod), do: [:nerves_interim_wifi | general_apps]
  defp applications(_), do: general_apps

  defp general_apps, do: [:runtime_tools, :logger, :nerves_firmware_http, :nerves_ntp, :ui, :thermostat]

  def deps do
    [
      {:nerves, "~> 0.3.0"},
      {:nerves_interim_wifi, "~> 0.1.0", only: :prod},
      {:nerves_ntp, "~> 0.1.0"},
      {:nerves_firmware_http, github: "nerves-project/nerves_firmware_http"},
      {:ui, in_umbrella: true},
      {:thermostat, in_umbrella: true},
      {:dummy_nerves, in_umbrella: true, only: [:dev, :test]}
   ]
  end

  def system(target, :prod) do
    [
      {:"nerves_system_#{target}", "~> 0.7"},
    ]
  end
  def system(_, _), do: []

  def aliases(:prod) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end
  def aliases(_), do: []

end
