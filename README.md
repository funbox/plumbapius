[![Build Status](https://travis-ci.com/funbox/plumbapius.svg?branch=master)](https://travis-ci.com/funbox/plumbapius)
[![Coverage Status](https://coveralls.io/repos/github/funbox/plumbapius/badge.svg?branch=master)](https://coveralls.io/github/funbox/plumbapius?branch=master)

<a href="https://funbox.ru">
  <img src="http://funbox.ru/badges/sponsored_by_funbox_compact.svg" alt="Sponsored by FunBox" width=250 />
</a>

# Plumbapius

Plumbapius is a tool for validation of http requests/responses according to API Blueprint specs.

It can be used both in test and production environments.

## Installation

```
def deps do
  [
    {:plumbapius, "~> 0.7.1"}
  ]
end
```

## Preparing json schema

Plumbapius requires conversion of apib to json schema.

Some mix tasks to make this process easier are included:

### plumbapius.get_docs

`mix plumbapius.get_docs -c ssh://git@some-repo.com/some-repo.git -b master`

Clones or updates repository with apib to local folder (it is usefull whet apib specs are in separate repo).

### plumbapius.setup_docs

`mix plumbapius.setup_docs --from ./.apib/api.apib --into doc.json`

Converts apib to json shema

It requires following tools to be installed (globally or in current Gemfile):

- drafter (https://github.com/apiaryio/drafter)
- tomograph (https://github.com/funbox/tomograph)

These tasks are supposed to be run manually and resulting json schema to be committed.

## Usage

Plumbapius implements Plug behaviour (https://hexdocs.pm/plug/Plug.html)

Plugs provided:

- `Plumbapius.Plug.LogValidationError` - logs errors
- `Plumbapius.Plug.SendToSentryValidationError` - posts errors to Sentry
- `Plumbapius.Plug.RaiseValidationError` - raises error (usefull for test environment)

## Examples

router.exs

```elixir
defmodule DogeApp.Api.Router do
  use DogeApp.Api, :router

  @json_schema_path "../../doc.json"

  @external_resource @json_schema_path
  @json_schema File.read!(@json_schema_path)

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Application.get_env(:doge_app, :plumbapius_plug), json_schema: @json_schema)
  end

 # ...

end
  ```

  test.exs:

  ```elixir
  config :doge_app, plumbapius_plug: Plumbapius.Plug.RaiseValidationError
  ```

  prod.exs:

  ```elixir
  config :doge_app, plumbapius_plug: Plumbapius.Plug.SendToSentryValidationError
  ```

## Usage in tests

In case you need to ignore Plumbapius validations (for error handling testing etc.), you can use `Plumbapius.ignore`

```elixir

 test "replies with error if request contains malformed json", %{conn: conn} do
      response =
        conn
        |> Plumbapius.ignore()
        |> post("", @bad_params)
        |> json_response(400)
    end

```

