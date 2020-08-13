defmodule FakeCoverageTracker do
  alias Plumbapius.Coverage.CoverageTracker
  @behaviour CoverageTracker

  @impl true
  def response_covered(covered_case) do
    send(self(), {:response_covered_called, covered_case})
  end
end
