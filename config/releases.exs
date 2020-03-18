import Config

config :line_bot,
  port: System.get_env("PORT", "4000") |> String.to_integer(),
  ssl: System.get_env("SSL", "false") |> String.to_atom(),
  base_url: System.get_env("BASE_URL", "http://localhost"),
  cacertfile: System.get_env("CACERTFILE", "/opt/certs/chain.pem"),
  certfile: System.get_env("CERTFILE", "/opt/certs/cert.pem"),
  keyfile: System.get_env("KEYFILE", "/opt/certs/privkey.pem"),
  proxy_header: System.get_env("PROXY_HEADER", "false") |> String.to_atom()

config :line_bot,
  access_token: System.get_env("LINE_ACCESS_TOKEN", ""),
  mongodb_url: System.get_env("MONGODB_URL", "mongodb://localhost:27017/test?MaxPoolSize=5")
