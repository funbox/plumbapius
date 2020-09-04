defmodule Plumbapius.Coverage.DefaultCoverageTrackerTest do
  use ExUnit.Case

  alias Plumbapius.Coverage.DefaultCoverageTracker
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase
  alias Plumbapius.Request.Schema, as: RequestSchema
  alias Plumbapius.Response.Schema, as: ResponseSchema
  alias Plumbapius.Coverage.Report.InteractionReport

  test "forms coverage report" do
    covered_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(200)], bodies: [%{schema: %{}}]}
    missed_schema = %RequestSchema{method: "GET", path: "/path2", responses: [response(500)], bodies: [%{schema: %{}}]}
    all_schemas = [covered_schema, missed_schema]

    start_supervised!({DefaultCoverageTracker, all_schemas})

    assert :ok = DefaultCoverageTracker.response_covered(CoveredCase.new({covered_schema, response(200)}))
    report = DefaultCoverageTracker.coverage_report()

    assert report.interaction_reports == [%InteractionReport{interaction: {covered_schema, response(200)}}]
    assert report.missed == [{missed_schema, response(500)}]
  end

  defp response(code) do
    %ResponseSchema{status: code, content_type: "", body: %{schema: %{}}}
  end
end
