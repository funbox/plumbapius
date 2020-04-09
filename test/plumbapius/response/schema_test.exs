defmodule Plumbapius.Response.SchemaTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Response.Schema

  alias Plumbapius.Response.Schema

  describe "Plumbapius.Response.Schema.new/1" do
    test "when the tomogram is a valid response schema" do
      assert Schema.new(tomogram_schema()) == %Schema{
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
    end

    test "when the tomogram without a status parameter" do
      tomogram_without_status = Map.delete(tomogram_schema(), "status")

      assert_raise KeyError, ~r/key "status" not found/, fn ->
        Schema.new(tomogram_without_status)
      end
    end

    test "when the tomogram without a content-type parameter" do
      tomogram_without_content_type = Map.delete(tomogram_schema(), "content-type")

      assert_raise KeyError, ~r/key "content-type" not found/, fn ->
        Schema.new(tomogram_without_content_type)
      end
    end

    test "when the tomogram without a body parameter" do
      tomogram_without_body = Map.delete(tomogram_schema(), "body")

      assert_raise KeyError, ~r/key "body" not found/, fn ->
        Schema.new(tomogram_without_body)
      end
    end

    test "when the tomogram with a wrong version of the schema" do
      tomogram_with_invalid_schema_version = %{
        "status" => "200",
        "content-type" => "application/json",
        "body" => %{
          "$schema" => "http://json-schema.org/draft-03/schema#",
          "type" => "object",
          "properties" => %{"msisdn" => %{"type" => "number"}},
          "required" => ["msisdn"]
        }
      }

      assert_raise ExJsonSchema.Schema.UnsupportedSchemaVersionError, ~r/only draft 4/, fn ->
        Schema.new(tomogram_with_invalid_schema_version)
      end
    end
  end

  defp tomogram_schema do
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
  end
end
