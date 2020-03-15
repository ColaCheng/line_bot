import Config

config :logger,
  level: :info

config :line_bot,
  port: System.get_env("PORT", "4000") |> String.to_integer(),
  ssl: System.get_env("SSL", "false") |> String.to_atom(),
  cacertfile: System.get_env("CACERTFILE", ""),
  certfile: System.get_env("CERTFILE", ""),
  keyfile: System.get_env("KEYFILE", "")

import_config "#{Mix.env()}.exs"
