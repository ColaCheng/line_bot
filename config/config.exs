import Config

config :logger,
  level: :info

config :line_bot,
  port: System.get_env("PORT", "4000") |> String.to_integer()

import_config "#{Mix.env()}.exs"
