defmodule Plumbapius.Coverage.CoverageTracker do
  alias Plumbapius.Request
  alias Plumbapius.Response

  @type t :: module()
  @type interaction :: {Request.Schema.t(), Response.Schema.t()}

  @callback response_covered(Request.Schema.t(), Response.Schema.t()) :: :ok
end
