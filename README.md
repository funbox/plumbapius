# Plumbapius

Plumbapius служит для валидации http запросов/ответов на соответсвие API Blueprint спецификации.
Его можно использовать как в тестовой, так и в продакшен среде.

## Установка

```
def deps do
  [
    {:plumbapius, "~> 0.3.0", repo: :funbox}
  ]
end
```

Про внутренний репозиторий Hex Funbox: https://wiki.funbox.ru/pages/viewpage.action?pageId=58327725

## Подготовка json schema

Для своей работы Plumbapius требует преобразования apib в json schema.

Для облегчения процесса в Plumbapius есть mix таски:

### plumbapius.get_docs

`mix plumbapius.get_docs -c ssh://git@git.funbox.ru/gc/ghetto-auth-apib.git -b master`

Клонирует или обновляет репозиторий с apib в локальную папку в проекте (для случаев, когда apib в отдельной репе).

### plumbapius.setup_docs

`mix plumbapius.setup_docs --from ./.apib/api.apib --into doc.json`

Преобразует apib в json schema

Ддя работы требуются:

- crafter (https://bb.funbox.ru/projects/APIB/repos/crafter)
- tomograph (https://github.com/funbox/tomograph)

Предполагается, что таски будут запускаться руками по необходимости, и получившийся файл doc.json будет комититься в git.

## Использование в проекте

Plumbapius реализует интерфейс Plug (https://hexdocs.pm/plug/Plug.html)

Доступные plugs по-разному обрабатывают несоответствие запросов/ответов спецификации:

- `Plumbapius.Plug.LogValidationError` - только логирует
- `Plumbapius.Plug.SendToSentryValidationError` - отправляет в Sentry
- `Plumbapius.Plug.RaiseValidationError` - выбрасывает ошибку, подходит для использования в тестах

## Пример использования

router.exs

```elixir
defmodule DogeApp.Api.Router do
  use DogeApp.Api, :router

  @json_schema_path "../../doc.json"

  # Файл вкомпиливается в модуль, поэтому при изменении файла,
  # необходимо перекомпилировать модуль
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

## Особенности использования в тестах

Иногда в тестах, чтобы проверить валидацию запросов или реакцию на ошибки, в аpi сознательно передаются данные, нарушающие спецификацию. Для таких случаев проверку Plumbapius можно отключить c помощью `Plumbapius.ignore`:

```elixir

 test "replies with error if request contains malformed json", %{conn: conn} do
      response =
        conn
        |> Plumbapius.ignore()
        |> post("", @bad_params)
        |> json_response(400)
    end

```

