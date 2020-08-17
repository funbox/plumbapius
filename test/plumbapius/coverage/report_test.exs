defmodule Plumbapius.Coverage.ReportTest do
  use ExUnit.Case, async: true

  alias Plumbapius.Coverage.Report
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase
  alias Plumbapius.Request.Schema, as: RequestSchema
  alias Plumbapius.Response.Schema, as: ResponseSchema
  alias Plumbapius.Coverage.Report.InteractionReport

  describe "#new" do
    test "creates report" do
      covered_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(200)], body: %{schema: %{}}}
      missed_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(500)], body: %{schema: %{}}}
      all_schemas = [covered_schema, missed_schema]

      covered_interaction = {covered_schema, response(200)}
      missed_interaction = {missed_schema, response(500)}

      report = Report.new(all_schemas, [CoveredCase.new(covered_interaction)])
      assert report.interaction_reports == [InteractionReport.new(covered_interaction)]
      assert report.missed == [missed_interaction]
    end
  end

  describe "#coverage" do
    test "returns coverage percentage" do
      covered_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(200)], body: %{schema: %{}}}
      missed_schema = %RequestSchema{method: "GET", path: "/path2", responses: [response(500)], body: %{schema: %{}}}
      all_schemas = [covered_schema, missed_schema]

      covered_interaction = {covered_schema, response(200)}
      assert Report.new(all_schemas, [CoveredCase.new(covered_interaction)]) |> Report.coverage() == 0.5
    end
  end

  describe "#multi_choice_coverage" do
    @json_schema %{
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => %{
        "kind" => %{
          "type" => "string",
          "enum" => [
            "textMessage",
            "fileMessage"
          ]
        }
      },
      "required" => [
        "kind"
      ]
    }

    test "returns coverage percentage including multichoices" do
      schema = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/some/path",
        responses: [response(200)],
        body: ExJsonSchema.Schema.resolve(@json_schema)
      }

      interaction = {schema, response(200)}
      req_body = %{"kind" => "textMessage"}
      assert Report.new([schema], [CoveredCase.new(interaction, req_body)]) |> Report.multi_choice_coverage() == 0.5
    end
  end

  describe "#ignore" do
    test "ignores interactions by string path" do
      schema1 = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/some/path",
        responses: [response(200)],
        body: %{schema: %{}}
      }

      schema2 = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/other/path",
        responses: [response(202)],
        body: %{schema: %{}}
      }

      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [CoveredCase.new({schema1, response(200)})])

      assert Report.ignore(report, [{"GET", "/other/path", :all}]) == %Report{
               multi_choices: %{{schema1, response(200)} => []},
               interaction_reports: [InteractionReport.new({schema1, response(200)})],
               covered: [{schema1, response(200)}],
               missed: []
             }
    end

    test "ignores interactions by regexp path" do
      schema1 = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/some/path",
        responses: [response(200)],
        body: %{schema: %{}}
      }

      schema2 = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/other/path",
        responses: [response(202)],
        body: %{schema: %{}}
      }

      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [CoveredCase.new({schema1, response(200)})])

      assert Report.ignore(report, [{"GET", ~r|/other/.+|, :all}]) == %Report{
               multi_choices: %{{schema1, response(200)} => []},
               interaction_reports: [InteractionReport.new({schema1, response(200)})],
               covered: [{schema1, response(200)}],
               missed: []
             }
    end

    test "ignores interactions by path and code" do
      schema1 = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/some/path",
        responses: [response(200)],
        body: %{schema: %{}}
      }

      schema2 = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/some/path",
        responses: [response(202)],
        body: %{schema: %{}}
      }

      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [CoveredCase.new({schema1, response(200)})])

      assert Report.ignore(report, [{"GET", ~r|/some/.+|, 202}]) == %Report{
               multi_choices: %{{schema1, response(200)} => []},
               interaction_reports: [InteractionReport.new({schema1, response(200)})],
               covered: [{schema1, response(200)}],
               missed: []
             }
    end

    test "ignores interactions by method" do
      schema1 = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/some/path",
        responses: [response(200)],
        body: %{schema: %{}}
      }

      schema2 = %RequestSchema{
        method: "POST",
        path: "",
        original_path: "/some/path",
        responses: [response(202)],
        body: %{schema: %{}}
      }

      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [CoveredCase.new({schema1, response(200)})])

      assert Report.ignore(report, [{:all, "/some/path", :all}]) == %Report{
               multi_choices: %{},
               interaction_reports: [],
               missed: []
             }
    end
  end

  defp response(code) do
    %ResponseSchema{status: code, content_type: "", body: %{schema: %{}}}
  end
end
