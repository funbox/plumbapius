defmodule Plumbapius.Coverage.Report.InteractionReport do
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase
  alias Plumbapius.Coverage.CoverageTracker
  alias Plumbapius.Coverage.Report.MultiChoiceSchema

  defstruct interaction: nil,
            covered_multi_choices: [],
            missed_multi_choices: []

  @type t :: %__MODULE__{
          interaction: CoverageTracker.interaction(),
          covered_multi_choices: list(MultiChoiceSchema.multi_choice()),
          missed_multi_choices: list(MultiChoiceSchema.multi_choice())
        }

  @spec new(CoveredCase.t()) :: t
  def new(%CoveredCase{} = covered_case) do
    {req_schema, resp_schema} = covered_case.interaction

    {covered_req_choices, missed_req_choices} = check_choices(req_schema, covered_case.req_body)
    {covered_resp_choices, missed_resp_choices} = check_choices(resp_schema, covered_case.resp_body)

    new(
      covered_case.interaction,
      covered_req_choices ++ covered_resp_choices,
      missed_req_choices ++ missed_resp_choices
    )
  end

  @spec new(
          CoverageTracker.interaction(),
          list(MultiChoiceSchema.multi_choice()),
          list(MultiChoiceSchema.multi_choice())
        ) :: t
  def new(interaction, covered_multi_choices \\ [], missed_multi_choices \\ []) do
    %__MODULE__{
      interaction: interaction,
      covered_multi_choices: covered_multi_choices,
      missed_multi_choices: missed_multi_choices
    }
  end

  defp check_choices(schema, body_to_check) do
    all_choices = MultiChoiceSchema.new(schema.body.schema)
    covered_choices = Enum.filter(all_choices, &choice_covered?(&1, schema.body, body_to_check))

    {covered_choices, all_choices -- covered_choices}
  end

  defp choice_covered?({path, choice_schema}, schema, body_to_check) do
    body_fragment = get_in(body_to_check, path)
    ExJsonSchema.Validator.valid_fragment?(schema, choice_schema, body_fragment)
  end
end
