defmodule Plumbapius.RequestTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request
  alias Plumbapius.Request
  alias ExJsonSchema.Validator.Error

  describe "#validate_body" do
    test "when the body according to the schema with 1 body option" do
      request_body = %{"msisdn" => 123, "last_name" => "Ivanov"}

      assert Request.validate_body(request_schema(), request_body) == :ok
    end

    test "when the body does not match the schema with 1 body option" do
      request_body = %{"msisdn" => "123"}
      request_schema = request_schema()
      [schema] = request_schema.bodies

      assert {:error, %{^schema => errors}} = Request.validate_body(request_schema, request_body)

      assert Enum.sort(errors) == [
               %Error{error: %Error.Required{missing: ["last_name"]}, path: "#"},
               %Error{error: %Error.Type{actual: "string", expected: ["number"]}, path: "#/msisdn"}
             ]
    end

    test "when the body according one of 2 body options of the schema" do
      schema = request_schema_with_two_requests()

      assert Request.validate_body(schema, %{"msisdn" => 123}) == :ok
      assert Request.validate_body(schema, %{"phoneNumber" => 123}) == :ok
    end

    test "when the body does not match any of 2 body options of the schema" do
      schema = request_schema_with_two_requests()

      msisdn_schema =
        Enum.find(schema.bodies, fn %{schema: schema} -> schema["properties"]["msisdn"] == %{"type" => "number"} end)

      phone_number_schema =
        Enum.find(schema.bodies, fn %{schema: schema} ->
          schema["properties"]["phoneNumber"] == %{"type" => "number"}
        end)

      assert Request.validate_body(schema, %{"msisdn" => "123"}) ==
               {:error,
                %{
                  msisdn_schema => [
                    %Error{error: %Error.Type{actual: "string", expected: ["number"]}, path: "#/msisdn"}
                  ],
                  phone_number_schema => [%Error{error: %Error.Required{missing: ["phoneNumber"]}, path: "#"}]
                }}

      assert Request.validate_body(schema, %{"phoneNumber" => "123"}) ==
               {:error,
                %{
                  msisdn_schema => [%Error{error: %Error.Required{missing: ["msisdn"]}, path: "#"}],
                  phone_number_schema => [
                    %Error{error: %Error.Type{actual: "string", expected: ["number"]}, path: "#/phoneNumber"}
                  ]
                }}
    end
  end

  describe "#match?" do
    test "when schema matches with the request" do
      assert Request.match?(request_schema(), "GET", "/users/1")
    end

    test "when request has a different method" do
      refute Request.match?(request_schema(), "GET", "/users")
    end

    test "when request has a different path" do
      refute Request.match?(request_schema(), "POST", "/users/1")
    end
  end

  defp request_schema do
    Request.Schema.new(%{
      "method" => "GET",
      "path" => "/users/{id}",
      "content-type" => "application/json",
      "request" => %{
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => %{"msisdn" => %{"type" => "number"}},
        "required" => ["msisdn", "last_name"]
      },
      "responses" => []
    })
  end

  defp request_schema_with_two_requests do
    Request.Schema.new(%{
      "method" => "GET",
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
      "responses" => []
    })
  end
end
