defmodule Plumbapius.Coverage.Report do
  alias Plumbapius.Coverage.CoverageTracker
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase
  alias Plumbapius.Coverage.Report.MultiChoiceSchema
  alias Plumbapius.Coverage.Report.InteractionReport
  alias Plumbapius.Request

  @type t :: %__MODULE__{
          multi_choices: %{optional(CoverageTracker.interaction()) => list(MultiChoiceSchema.multi_choice())},
          missed: list(CoverageTracker.interaction()),
          covered: list(CoverageTracker.interaction()),
          interaction_reports: list(InteractionReport.t())
        }

  defstruct multi_choices: %{},
            missed: [],
            covered: [],
            interaction_reports: []

  @spec new(list(Request.Schema.t()), list(CoveredCase.t())) :: t
  def new(schema, covered_cases) do
    all_interactions = Enum.flat_map(schema, &request_interactions/1)

    covered_interactions =
      covered_cases
      |> Enum.map(& &1.interaction)
      |> Enum.uniq()

    %__MODULE__{
      multi_choices: MultiChoiceSchema.multi_choices(all_interactions),
      covered: covered_interactions,
      missed: all_interactions -- covered_interactions,
      interaction_reports: Enum.map(covered_cases, &InteractionReport.new/1)
    }
  end

  @spec coverage(t) :: float
  def coverage(report) do
    covered_count = Enum.count(report.covered)
    missed_count = Enum.count(report.missed)
    covered_count / (covered_count + missed_count)
  end

  @spec multi_choice_coverage(t) :: float
  def multi_choice_coverage(report) do
    total =
      Enum.reduce(report.multi_choices, 0, fn {_, choices}, acc ->
        acc + max(Enum.count(choices), 1)
      end)

    covered_count =
      Enum.reduce(report.interaction_reports, 0, fn report, acc ->
        acc + max(Enum.count(report.covered_multi_choices), 1)
      end)

    covered_count / total
  end

  @type ignore_pattern :: {method :: String.t() | atom, path :: String.t() | Regex.t(), status :: pos_integer() | :all}

  @spec ignore(t, list(ignore_pattern)) :: t
  def ignore(report, patterns) do
    %__MODULE__{
      multi_choices: reject_multi_choices(report.multi_choices, patterns),
      covered: reject_interactions(report.covered, patterns),
      missed: reject_interactions(report.missed, patterns),
      interaction_reports: reject_reports(report.interaction_reports, patterns)
    }
  end

  defp reject_multi_choices(interactions, patterns) do
    interactions
    |> Enum.reject(fn {interaction, _} -> Enum.any?(patterns, &matches?(interaction, &1)) end)
    |> Enum.into(%{})
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
