defmodule Plumbapius.Coverage.NullCoverageTracker do
  alias Plumbapius.Coverage.CoverageTracker

  @behaviour CoverageTracker

  @impl true
  def response_covered(_covered_case) do
    :ok
  end
end
