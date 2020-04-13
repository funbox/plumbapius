import Config

config :sentry,
  dsn:
    "http://210d058342a64f9e92b84548489188ed:25a16e545e764ae58a4101343bf567f9@sentry.funbox.ru/90",
  included_environments: [Mix.env()],
  environment_name: Mix.env(),
  enable_source_code_context: true,
  tags: %{"service" => "plumbapius"}

import_config "#{Mix.env()}.exs"
