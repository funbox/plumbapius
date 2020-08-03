defmodule Plumbapius.ResponseTest do
  use ExUnit.Case, async: true

  alias Plumbapius.Response
  alias Plumbapius.Request

  describe "#validate_response" do
    test "response is valid" do
      assert {:ok, _response_schema} =
               Response.validate_response(request_schema(), 200, "application/json", %{"field_name" => "foobar"})
    end

    test "response has invalid body" do
      assert Response.validate_response(request_schema(), 200, "application/json", %{"wrong_field_name" => "12345"}) ==
               {:error, "no_such_response_in_schema"}
    end

    test "response has invalid content-type" do
      assert Response.validate_response(request_schema(), 200, "text/plain", %{"field_name" => "foobar"}) ==
               {:error, "no_such_response_in_schema"}
    end

    test "response has invalid status" do
      assert Response.validate_response(request_schema(), 401, "application/json", %{"field_name" => "foobar"}) ==
               {:error, "no_such_response_in_schema"}
    end
  end

  defp request_schema do
    Request.Schema.new(%{
      "method" => "GET",
      "path" => "/users",
      "content-type" => "application/json",
      "request" => %{
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => %{"msisdn" => %{"type" => "number"}},
        "required" => ["msisdn"]
      },
      "responses" => [
        %{
          "content-type" => "application/json",
          "status" => "200",
          "body" => %{
            "$schema" => "http://json-schema.org/draft-04/schema#",
            "type" => "object",
            "properties" => %{
              "field_name" => %{"type" => "string"}
            },
            "required" => ["field_name"]
          }
        }
      ]
    })
  end
end
