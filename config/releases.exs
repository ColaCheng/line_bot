import Config

config :line_bot,
  port: System.get_env("PORT", "4000") |> String.to_integer(),
  ssl: System.get_env("SSL", "false") |> String.to_atom(),
  cacertfile: System.get_env("CACERTFILE", "/opt/certs/chain.pem"),
  certfile: System.get_env("CERTFILE", "/opt/certs/cert.pem"),
  keyfile: System.get_env("KEYFILE", "/opt/certs/privkey.pem")

config :line_bot,
  access_token: System.get_env("LINE_ACCESS_TOKEN", "")
