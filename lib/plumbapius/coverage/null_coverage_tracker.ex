defmodule Plumbapius.Coverage.NullCoverageTracker do
  alias Plumbapius.Coverage.CoverageTracker

  @behaviour CoverageTracker

  @impl true
  def response_covered(_request_schema, _response_schema) do
    :ok
  end
end
