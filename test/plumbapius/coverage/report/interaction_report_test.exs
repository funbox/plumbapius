defmodule Plumbapius.Coverage.Report.InteractionReportTest do
  use ExUnit.Case

  alias Plumbapius.Request.Schema, as: RequestSchema
  alias Plumbapius.Response.Schema, as: ResponseSchema
  alias Plumbapius.Coverage.Report.InteractionReport
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase

  @json_schema %{
    "type" => "object",
    "properties" => %{
      "root" => %{
        "type" => "object",
        "properties" => %{
          "message" => %{
            "type" => "object",
            "oneOf" => [
              %{"properties" => %{"textMessage" => %{"type" => "string"}}, "required" => ["textMessage"]},
              %{"properties" => %{"fileMessage" => %{"type" => "string"}}, "required" => ["fileMessage"]}
            ]
          },
          "priority" => %{
            "type" => "string",
            "enum" => ["high", "low"]
          }
        },
        "required" => ["message", "priority"]
      }
    }
  }

  test "reports covered and uncovered multiple choices for requests" do
    req_schema = %RequestSchema{
      method: "POST",
      path: "",
      original_path: "/some/path",
      responses: [],
      bodies: [ExJsonSchema.Schema.resolve(@json_schema)]
    }

    resp_schema = %ResponseSchema{
      status: 200,
      content_type: "",
      body: %{schema: %{}}
    }

    req_body = %{"root" => %{"message" => %{"textMessage" => "WOW"}, "priority" => "high"}}
    resp_body = %{}

    report = InteractionReport.new(CoveredCase.new({req_schema, resp_schema}, req_body, resp_body))

    assert report.covered_multi_choices() == [
             {["root", "message"],
              %{
                "properties" => %{"textMessage" => %{"type" => "string"}},
                "required" => ["textMessage"],
                "type" => "object"
              }},
             {["root", "priority"], %{"enum" => ["high"], "type" => "string"}}
           ]

    assert report.missed_multi_choices() == [
             {["root", "message"],
              %{
                "properties" => %{"fileMessage" => %{"type" => "string"}},
                "required" => ["fileMessage"],
                "type" => "object"
              }},
             {["root", "priority"], %{"enum" => ["low"], "type" => "string"}}
           ]
  end

  test "reports covered and uncovered multiple choices for responses" do
    req_schema = %RequestSchema{
      method: "POST",
      path: "",
      original_path: "/some/path",
      responses: [],
      bodies: [%{schema: %{}}]
    }

    resp_schema = %ResponseSchema{
      status: 200,
      content_type: "",
      body: ExJsonSchema.Schema.resolve(@json_schema)
    }

    req_body = %{}
    resp_body = %{"root" => %{"message" => %{"fileMessage" => "WOW"}, "priority" => "low"}}

    report = InteractionReport.new(CoveredCase.new({req_schema, resp_schema}, req_body, resp_body))

    assert report.covered_multi_choices() == [
             {["root", "message"],
              %{
                "properties" => %{"fileMessage" => %{"type" => "string"}},
                "required" => ["fileMessage"],
                "type" => "object"
              }},
             {["root", "priority"], %{"enum" => ["low"], "type" => "string"}}
           ]

    assert report.missed_multi_choices() == [
             {["root", "message"],
              %{
                "properties" => %{"textMessage" => %{"type" => "string"}},
                "required" => ["textMessage"],
                "type" => "object"
              }},
             {["root", "priority"], %{"enum" => ["high"], "type" => "string"}}
           ]
  end
end
