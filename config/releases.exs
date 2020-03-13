import Config

config :line_bot,
  port: System.get_env("PORT", "4000") |> String.to_integer()
