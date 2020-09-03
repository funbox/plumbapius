defmodule Plumbapius.Request.SchemaTest do
  use ExUnit.Case, async: true

  alias Plumbapius.Request.Schema, as: RequestSchema
  alias Plumbapius.Request.Schema.NotFoundReqestsParametersError

  doctest RequestSchema

  describe "#new" do
    test "when the tomogram is a valid request schema with 1 body option in 'request' parameter" do
      expected_request_schema = %RequestSchema{
        method: "POST",
        original_path: "/users/{id}",
        path: ~r/\A\/users\/[^&=\/]+\z/,
        content_type: "application/json",
        bodies: [
          %ExJsonSchema.Schema.Root{
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
        ],
        responses: [
          %Plumbapius.Response.Schema{
            status: 200,
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

      assert RequestSchema.new(tomogram_schema()) == expected_request_schema
    end

    test "when the tomogram is a valid request schema with 2 body options in 'requests' parameter" do
      tomogram_schema = %{
        "method" => "POST",
        "path" => "/users/{id}",
        "content-type" => "application/json",
        "requests" => [
          %{
            "$schema" => "http://json-schema.org/draft-04/schema#",
            "type" => "object",
            "properties" => %{"msisdn" => %{"type" => "number"}},
            "required" => ["msisdn"]
          },
          %{
            "$schema" => "http://json-schema.org/draft-04/schema#",
            "type" => "object",
            "properties" => %{"phoneNumber" => %{"type" => "number"}},
            "required" => ["phoneNumber"]
          }
        ],
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

      expected_request_schema = %RequestSchema{
        method: "POST",
        original_path: "/users/{id}",
        path: ~r/\A\/users\/[^&=\/]+\z/,
        content_type: "application/json",
        bodies: [
          %ExJsonSchema.Schema.Root{
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
          %ExJsonSchema.Schema.Root{
            custom_format_validator: nil,
            location: :root,
            refs: %{},
            schema: %{
              "$schema" => "http://json-schema.org/draft-04/schema#",
              "type" => "object",
              "properties" => %{"phoneNumber" => %{"type" => "number"}},
              "required" => ["phoneNumber"]
            }
          }
        ],
        responses: [
          %Plumbapius.Response.Schema{
            status: 200,
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

      assert RequestSchema.new(tomogram_schema) == expected_request_schema
    end

    test "when the tomogram without a method parameter" do
      tomogram_without_method = Map.delete(tomogram_schema(), "method")

      assert_raise KeyError, ~r/key "method" not found/, fn ->
        RequestSchema.new(tomogram_without_method)
      end
    end

    test "when the tomogram without a path parameter" do
      tomogram_without_path = Map.delete(tomogram_schema(), "path")

      assert_raise KeyError, ~r/key "path" not found/, fn ->
        RequestSchema.new(tomogram_without_path)
      end
    end

    test "when the tomogram without a content_type parameter" do
      tomogram_without_content_type = Map.delete(tomogram_schema(), "content-type")

      assert_raise KeyError, ~r/key "content-type" not found/, fn ->
        RequestSchema.new(tomogram_without_content_type)
      end
    end

    test "when the tomogram without a request or requests parameters" do
      tomogram_without_request = Map.delete(tomogram_schema(), "request")

      assert_raise NotFoundReqestsParametersError,
                   ~r/Not found 'reqest' or 'reqests' parameters in tomogram schema:/,
                   fn ->
                     RequestSchema.new(tomogram_without_request)
                   end
    end

    test "when the tomogram without a responses parameter" do
      tomogram_without_responses = Map.delete(tomogram_schema(), "responses")

      assert_raise KeyError, ~r/key "responses" not found/, fn ->
        RequestSchema.new(tomogram_without_responses)
      end
    end

    test "when the tomogram with a wrong version of the schema" do
      tomogram_with_invalid_schema_version = %{
        "method" => "POST",
        "path" => "/users/{id}",
        "content-type" => "application/json",
        "request" => %{
          "$schema" => "http://json-schema.org/draft-03/schema#",
          "type" => "object",
          "properties" => %{"msisdn" => %{"type" => "number"}},
          "required" => ["msisdn"]
        },
        "responses" => []
      }

      assert_raise ExJsonSchema.Schema.UnsupportedSchemaVersionError, ~r/only draft 4/, fn ->
        RequestSchema.new(tomogram_with_invalid_schema_version)
      end
    end
  end

  defp tomogram_schema do
    %{
      "method" => "POST",
      "path" => "/users/{id}",
      "content-type" => "application/json",
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
