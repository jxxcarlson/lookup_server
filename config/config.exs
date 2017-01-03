# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lookup_phoenix,
  ecto_repos: [LookupPhoenix.Repo]

# Configures the endpoint
config :lookup_phoenix, LookupPhoenix.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NCRIi0mLUGO10aY0NiQOdR/koQKu5av0091x9TpguKOud86+QK4zYAhJ1OV9Kj9R",
  render_errors: [view: LookupPhoenix.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LookupPhoenix.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
