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

  defp response(code) do
    %ResponseSchema{status: code, content_type: "", body: ""}
  end
end
