defmodule Plumbapius.RequestTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request
  alias Plumbapius.Request

  describe "Plumbapius.Request.validate_request/2" do
    test "when the request according to the scheme" do
      request_body = %{"msisdn" => 123}

      assert Request.validate_request(request_schema(), request_body) == :ok
    end

    test "when the msisdn in the request is string" do
      request_body = %{"msisdn" => "123"}

      assert Request.validate_request(request_schema(), request_body) ==
               {:error, [{"Type mismatch. Expected Number but got String.", "#/msisdn"}]}
    end
  end

  describe "Plumbapius.Request.match?/3" do
    test "when the schema matches for the request" do
      request_method = "GET"
      request_path = "/users/1"
      content_type = "application/json"

      assert Request.match?(request_schema(), request_method, request_path, content_type)
    end

    test "when the request has a different method" do
      request_method = "GET"
      request_path = "/users"
      content_type = "application/json"

      refute Request.match?(request_schema(), request_method, request_path, content_type)
    end

    test "when the request has a different path" do
      request_method = "POST"
      request_path = "/users/1"
      content_type = "application/json"

      refute Request.match?(request_schema(), request_method, request_path, content_type)
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
end
