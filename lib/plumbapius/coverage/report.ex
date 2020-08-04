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

  @type ignore_pattern :: {method :: String.t() | atom, path :: String.t() | Regex.t(), status :: pos_integer() | :all}

  @spec ignore(t, list(ignore_pattern)) :: t
  def ignore(report, patterns) do
    %__MODULE__{
      all: reject_interactions(report.all, patterns),
      missed: reject_interactions(report.missed, patterns),
      covered: reject_interactions(report.covered, patterns)
    }
  end

  defp reject_interactions(interactions, patterns) do
    Enum.reject(interactions, fn interaction ->
      Enum.any?(patterns, &matches?(interaction, &1))
    end)
  end

  defp matches?({request, response}, {method, path_pattern, status}) do
    matches_method?(request.method, method) &&
      matches_path?(request.original_path, path_pattern) &&
      (status == :all || response.status == status)
  end

  defp matches_method?(method, pattern) do
    pattern == :all || to_string(pattern) |> String.downcase() == String.downcase(method)
  end

  defp matches_path?(path, %Regex{} = pattern) do
    String.match?(path, pattern)
  end

  defp matches_path?(path, pattern) do
    path == pattern
  end

  defp request_interactions(request) do
    Enum.map(request.responses, &{request, &1})
  end
end
