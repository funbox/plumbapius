import Config

config :sentry,
  dsn: "https://public_key@app.getsentry.com/1",
  environment_name: Mix.env(),
  included_environments: [:prod],
  enable_source_code_context: true,
  root_source_code_path: File.cwd!()

import_config "#{Mix.env()}.exs"
