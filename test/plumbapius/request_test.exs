defmodule Plumbapius.RequestTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request
  alias Plumbapius.Request
  alias Plumbapius.Request.NotFoundSchemaForReqestBodyError

  describe "#validate_body" do
    test "when the body according to the schema with 1 body option" do
      request_body = %{"msisdn" => 123}

      assert Request.validate_body(request_schema(), request_body) == :ok
    end

    test "when the body does not match the schema with 1 body option" do
      request_body = %{"msisdn" => "123"}

      assert Request.validate_body(request_schema(), request_body) == {:error, %NotFoundSchemaForReqestBodyError{}}
    end

    test "when the body according one of 2 body options of the schema" do
      schema = request_schema_with_two_requests()

      assert Request.validate_body(schema, %{"msisdn" => 123}) == :ok
      assert Request.validate_body(schema, %{"phoneNumber" => 123}) == :ok
    end

    test "when the body does not match any of 2 body options of the schema" do
      schema = request_schema_with_two_requests()

      assert Request.validate_body(schema, %{"msisdn" => "123"}) == {:error, %NotFoundSchemaForReqestBodyError{}}
      assert Request.validate_body(schema, %{"phoneNumber" => "123"}) == {:error, %NotFoundSchemaForReqestBodyError{}}
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
        "required" => ["msisdn"]
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
