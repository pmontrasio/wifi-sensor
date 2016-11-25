# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :sensor,
  wlan: "wlan1",
  max_channel: 12,
  ms_per_channel: 5_000,
  collection_period: 60_000

# To demostrate how to handle multiple config files.
# Useful for secrets not to be checked into version control.
import_config "secrets.exs"

