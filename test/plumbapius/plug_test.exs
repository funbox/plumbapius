defmodule Plumbapius.PlugTest do
  use ExUnit.Case

  alias Plumbapius.Plug.IncorrectSchemaError

  test "parse file which does not exist raise IncorrectSchemaError" do
    init_options = [apib_json_filepath: "incorrect/path/file.json"]

    assert_raise IncorrectSchemaError, "{:error, :enoent}", fn ->
      Plumbapius.Plug.init(init_options)
    end
  end

  test "parse file with incorrect json structure raise IncorrectSchemaError" do
    init_options = [apib_json_filepath: "test/fixtures/incorrect_schema.json"]

    assert_raise IncorrectSchemaError, "{:error, {:invalid, \"]\", 31}}", fn ->
      Plumbapius.Plug.init(init_options)
    end
  end

  test "parse correct json file" do
    init_options = [apib_json_filepath: "test/fixtures/correct_schema.json"]

    assert Plumbapius.Plug.init(init_options) ==
             [
               schema: [
                 %Plumbapius.Request.Schema{
                   body: %ExJsonSchema.Schema.Root{
                     custom_format_validator: nil,
                     location: :root,
                     refs: %{},
                     schema: %{
                       "$schema" => "http://json-schema.org/draft-04/schema#",
                       "properties" => %{
                         "captcha" => %{"type" => "string"},
                         "login" => %{"type" => "string"},
                         "password" => %{"type" => "string"}
                       },
                       "required" => ["login", "password"],
                       "type" => "object"
                     }
                   },
                   content_type: "application/json",
                   method: "POST",
                   path: ~r/\A\/sessions\z/,
                   responses: [
                     %Plumbapius.Response.Schema{
                       body: %ExJsonSchema.Schema.Root{
                         custom_format_validator: nil,
                         location: :root,
                         refs: %{},
                         schema: %{}
                       },
                       content_type: "application/json",
                       status: "401"
                     },
                     %Plumbapius.Response.Schema{
                       body: %ExJsonSchema.Schema.Root{
                         custom_format_validator: nil,
                         location: :root,
                         refs: %{},
                         schema: %{}
                       },
                       content_type: "application/json",
                       status: "429"
                     },
                     %Plumbapius.Response.Schema{
                       body: %ExJsonSchema.Schema.Root{
                         custom_format_validator: nil,
                         location: :root,
                         refs: %{},
                         schema: %{
                           "$schema" => "http://json-schema.org/draft-04/schema#",
                           "properties" => %{
                             "captcha" => %{"type" => "string"},
                             "captcha_does_not_match" => %{"type" => "boolean"},
                             "confirmation" => %{
                               "properties" => %{
                                 "id" => %{"type" => "string"},
                                 "operation" => %{"type" => "string"},
                                 "type" => %{"type" => "string"}
                               },
                               "required" => ["id", "type", "operation"],
                               "type" => "object"
                             }
                           },
                           "type" => "object"
                         }
                       },
                       content_type: "application/json",
                       status: "201"
                     }
                   ]
                 }
               ]
             ]
  end
end
