defmodule Plumbapius.Coverage.DefaultCoverageTrackerTest do
  use ExUnit.Case

  alias Plumbapius.Coverage.DefaultCoverageTracker
  alias Plumbapius.Request.Schema, as: RequestSchema
  alias Plumbapius.Response.Schema, as: ResponseSchema

  test "forms coverage report" do
    covered_schema = %RequestSchema{method: "GET", path: "/path1", responses: [response(200)]}
    missed_schema = %RequestSchema{method: "GET", path: "/path2", responses: [response(500)]}
    all_schemas = [covered_schema, missed_schema]

    start_supervised!({DefaultCoverageTracker, all_schemas})

    assert :ok = DefaultCoverageTracker.response_covered(covered_schema, response(200))
    report = DefaultCoverageTracker.coverage_report()

    assert report.covered == [{covered_schema, response(200)}]
    assert report.missed == [{missed_schema, response(500)}]
  end

  defp response(code) do
    %ResponseSchema{status: code, content_type: "", body: ""}
  end
end
