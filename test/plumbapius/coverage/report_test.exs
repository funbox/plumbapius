defmodule Plumbapius.Coverage.ReportTest do
  use ExUnit.Case, async: true

  alias Plumbapius.Coverage.Report
  alias Plumbapius.Request.Schema, as: RequestSchema
  alias Plumbapius.Response.Schema, as: ResponseSchema

  describe "#new" do
    test "creates report" do
      covered_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(200)]}
      missed_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(500)]}
      all_schemas = [covered_schema, missed_schema]

      covered_interaction = {covered_schema, response(200)}
      missed_interaction = {missed_schema, response(500)}

      report = Report.new(all_schemas, [covered_interaction])
      assert report.all == [covered_interaction, missed_interaction]
      assert report.covered == [covered_interaction]
      assert report.missed == [missed_interaction]
    end
  end

  describe "#coverage" do
    test "returns coverage percentage" do
      covered_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(200)]}
      missed_schema = %RequestSchema{method: "GET", path: "/path2", responses: [response(500)]}
      all_schemas = [covered_schema, missed_schema]

      covered_interaction = {covered_schema, response(200)}
      assert Report.new(all_schemas, [covered_interaction]) |> Report.coverage() == 0.5
    end
  end

  describe "#ignore" do
    test "ignores interactions by string path" do
      schema1 = %RequestSchema{method: "GET", path: "", original_path: "/some/path", responses: [response(200)]}
      schema2 = %RequestSchema{method: "GET", path: "", original_path: "/other/path", responses: [response(202)]}
      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [{schema1, response(200)}])

      assert Report.ignore(report, [{"GET", "/other/path", :all}]) == %Report{
               all: [{schema1, response(200)}],
               covered: [{schema1, response(200)}],
               missed: []
             }
    end

    test "ignores interactions by regexp path" do
      schema1 = %RequestSchema{method: "GET", path: "", original_path: "/some/path", responses: [response(200)]}
      schema2 = %RequestSchema{method: "GET", path: "", original_path: "/other/path", responses: [response(202)]}
      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [{schema1, response(200)}])

      assert Report.ignore(report, [{"GET", ~r|/other/.+|, :all}]) == %Report{
               all: [{schema1, response(200)}],
               covered: [{schema1, response(200)}],
               missed: []
             }
    end

    test "ignores interactions by path and code" do
      schema1 = %RequestSchema{method: "GET", path: "", original_path: "/some/path", responses: [response(200)]}
      schema2 = %RequestSchema{method: "GET", path: "", original_path: "/some/path", responses: [response(202)]}
      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [{schema1, response(200)}])

      assert Report.ignore(report, [{"GET", ~r|/some/.+|, 202}]) == %Report{
               all: [{schema1, response(200)}],
               covered: [{schema1, response(200)}],
               missed: []
             }
    end

    test "ignores interactions by method" do
      schema1 = %RequestSchema{method: "GET", path: "", original_path: "/some/path", responses: [response(200)]}
      schema2 = %RequestSchema{method: "POST", path: "", original_path: "/some/path", responses: [response(202)]}
      all_schemas = [schema1, schema2]

      report = Report.new(all_schemas, [{schema1, response(200)}])

      assert Report.ignore(report, [{:all, "/some/path", :all}]) == %Report{
               all: [],
               covered: [],
               missed: []
             }
    end
  end

  defp response(code) do
    %ResponseSchema{status: code, content_type: "", body: ""}
  end
end
