defmodule Plumbapius.Request.SchemaTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request.Schema

  describe "Plumbapius.Request.Schema.new/1" do
    test "when the tomogram is a valid request schema" do
      assert Plumbapius.Request.Schema.new(tomogram_schema()) == %Plumbapius.Request.Schema{
               method: "POST",
               path: ~r/\A\/users\/[^&=\/]+\z/,
               content_type: "multipart/form-data",
               body: %ExJsonSchema.Schema.Root{
                 custom_format_validator: nil,
                 location: :root,
                 refs: %{},
                 schema: %{
                   "$schema" => "http://json-schema.org/draft-04/schema#",
                   "type" => "object",
                   "properties" => %{"msisdn" => %{"type" => "number"}},
                   "required" => ["msisdn"]
                 }
               },
               responses: [
                 %Plumbapius.Response.Schema{
                   status: "200",
                   content_type: "application/json",
                   body: %ExJsonSchema.Schema.Root{
                     custom_format_validator: nil,
                     location: :root,
                     refs: %{},
                     schema: %{
                       "$schema" => "http://json-schema.org/draft-04/schema#",
                       "type" => "object",
                       "properties" => %{"msisdn" => %{"type" => "number"}},
                       "required" => ["msisdn"]
                     }
                   }
                 }
               ]
             }
    end

    test "when the tomogram without a method parameter" do
      tomogram_without_method = Map.delete(tomogram_schema(), "method")

      assert_raise KeyError, ~r/key "method" not found/, fn ->
        Plumbapius.Request.Schema.new(tomogram_without_method)
      end
    end

    test "when the tomogram without a path parameter" do
      tomogram_without_path = Map.delete(tomogram_schema(), "path")

      assert_raise KeyError, ~r/key "path" not found/, fn ->
        Plumbapius.Request.Schema.new(tomogram_without_path)
      end
    end

    test "when the tomogram without a content_type parameter" do
      tomogram_without_content_type = Map.delete(tomogram_schema(), "content-type")

      assert_raise KeyError, ~r/key "content-type" not found/, fn ->
        Plumbapius.Request.Schema.new(tomogram_without_content_type)
      end
    end

    test "when the tomogram without a request parameter" do
      tomogram_without_request = Map.delete(tomogram_schema(), "request")

      assert_raise KeyError, ~r/key "request" not found/, fn ->
        Plumbapius.Request.Schema.new(tomogram_without_request)
      end
    end

    test "when the tomogram without a responses parameter" do
      tomogram_without_responses = Map.delete(tomogram_schema(), "responses")

      assert_raise KeyError, ~r/key "responses" not found/, fn ->
        Plumbapius.Request.Schema.new(tomogram_without_responses)
      end
    end

    test "when the tomogram with a wrong version of the schema" do
      tomogram_with_invalid_schema_version = %{
        "method" => "POST",
        "path" => "/users/{id}",
        "content-type" => "multipart/form-data",
        "request" => %{
          "$schema" => "http://json-schema.org/draft-03/schema#",
          "type" => "object",
          "properties" => %{"msisdn" => %{"type" => "number"}},
          "required" => ["msisdn"]
        },
        "responses" => []
      }

      assert_raise ExJsonSchema.Schema.UnsupportedSchemaVersionError, ~r/only draft 4/, fn ->
        Plumbapius.Request.Schema.new(tomogram_with_invalid_schema_version)
      end
    end
  end

  defp tomogram_schema do
    %{
      "method" => "POST",
      "path" => "/users/{id}",
      "content-type" => "multipart/form-data",
      "request" => %{
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => %{"msisdn" => %{"type" => "number"}},
        "required" => ["msisdn"]
      },
      "responses" => [
        %{
          "status" => "200",
          "content-type" => "application/json",
          "body" => %{
            "$schema" => "http://json-schema.org/draft-04/schema#",
            "type" => "object",
            "properties" => %{"msisdn" => %{"type" => "number"}},
            "required" => ["msisdn"]
          }
        }
      ]
    }
  end
end
