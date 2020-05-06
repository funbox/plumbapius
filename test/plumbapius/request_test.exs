defmodule Plumbapius.RequestTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request
  alias Plumbapius.Request

  describe "Plumbapius.Request.validate/2" do
    test "when the request according to the scheme" do
      request_body = %{"msisdn" => 123}

      assert Request.validate(request_schema(), request_body) == :ok
    end

    test "when the msisdn in the request is string" do
      request_body = %{"msisdn" => "123"}

      assert Request.validate(request_schema(), request_body) ==
               {:error, [{"Type mismatch. Expected Number but got String.", "#/msisdn"}]}
    end
  end

  describe "Plumbapius.Request.match?/3" do
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

  describe "Plumbapius.Request.match_content_type?/2" do
    test "always matches missing content type" do
      assert Request.match_content_type?(request_schema(), nil)
    end

    test "matches content type" do
      assert Request.match_content_type?(request_schema(), "application/json")
      refute Request.match_content_type?(request_schema(), "doge/dummy")
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
