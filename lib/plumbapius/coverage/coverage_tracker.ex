defmodule Plumbapius.Coverage.CoverageTracker do
  alias Plumbapius.Request
  alias Plumbapius.Response

  @type t :: module()
  @type interaction :: {Request.Schema.t(), Response.Schema.t()}

  defmodule CoveredCase do
    alias Plumbapius.Coverage.CoverageTracker

    defstruct interaction: nil,
              req_body: %{},
              resp_body: %{}

    @type t :: %__MODULE__{
            interaction: CoverageTracker.interaction(),
            req_body: map,
            resp_body: map
          }

    @spec new(CoverageTracker.interaction(), map, map) :: t
    def new(interaction, req_body \\ %{}, resp_body \\ %{}) do
      %__MODULE__{interaction: interaction, req_body: req_body, resp_body: resp_body}
    end
  end

  @callback response_covered(CoveredCase.t()) :: :ok
end
