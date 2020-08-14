defmodule Plumbapius.Coverage.Report do
  alias Plumbapius.Coverage.CoverageTracker
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase
  alias Plumbapius.Coverage.Report.InteractionReport
  alias Plumbapius.Request

  @type t :: %__MODULE__{
          missed: list(CoverageTracker.interaction()),
          covered: list(CoverageTracker.interaction())
        }

  defstruct multi_choices: %{},
            missed: [],
            covered: []

  @spec new(list(Request.Schema.t()), list(CoveredCase.t())) :: t
  def new(schema, covered_cases) do
    all_interactions = Enum.flat_map(schema, &request_interactions/1)
    covered_interactions = Enum.map(covered_cases, & &1.interaction)

    %__MODULE__{
      missed: all_interactions -- covered_interactions,
      covered: Enum.map(covered_cases, &InteractionReport.new/1)
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
      missed: reject_interactions(report.missed, patterns),
      covered: reject_reports(report.covered, patterns)
    }
  end

  defp reject_interactions(interactions, patterns) do
    Enum.reject(interactions, fn interaction ->
      Enum.any?(patterns, &matches?(interaction, &1))
    end)
  end

  defp reject_reports(reports, patterns) do
    Enum.reject(reports, fn report ->
      Enum.any?(patterns, &matches?(report.interaction, &1))
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
