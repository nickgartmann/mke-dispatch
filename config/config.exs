# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mke_police,
  ecto_repos: [MkePolice.Repo]

# Configures the endpoint
config :mke_police, MkePolice.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XNjt2sRDPAjHA2hkEfHZLFp1svCzrS2y8BE7+EVfoHf7cVxKZpqAKqCC8RlBvZ8n",
  render_errors: [view: MkePolice.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MkePolice.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
