defmodule Plumbapius.Coverage.Report do
  alias Plumbapius.Coverage.CoverageTracker
  alias Plumbapius.Request

  @type t :: %__MODULE__{
          all: list(CoverageTracker.interaction()),
          missed: list(CoverageTracker.interaction()),
          covered: list(CoverageTracker.interaction())
        }

  defstruct all: [],
            missed: [],
            covered: []

  @spec new(list(Request.Schema.t()), list(CoverageTracker.interaction())) :: t
  def new(schema, covered_interactions) do
    all_interactions = Enum.flat_map(schema, &request_interactions/1)

    %__MODULE__{
      all: all_interactions,
      missed: all_interactions -- covered_interactions,
      covered: covered_interactions
    }
  end

  @spec coverage(t) :: float
  def coverage(report) do
    covered_count = Enum.count(report.covered)
    missed_count = Enum.count(report.missed)
    covered_count / (covered_count + missed_count)
  end

  defp request_interactions(request) do
    Enum.map(request.responses, &{request, &1})
  end
end
