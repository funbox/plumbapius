defmodule FakeCoverageTracker do
  alias Plumbapius.Coverage.CoverageTracker
  @behaviour CoverageTracker

  @impl true
  def response_covered(request_schema, response_schema) do
    send(self(), {:response_covered_called, request_schema, response_schema})
  end
end
