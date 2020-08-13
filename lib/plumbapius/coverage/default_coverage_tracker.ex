defmodule Plumbapius.Coverage.DefaultCoverageTracker do
  use GenServer
  alias Plumbapius.Coverage.CoverageTracker
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase
  alias Plumbapius.Coverage.Report
  alias Plumbapius.Request

  @behaviour CoverageTracker

  defmodule State do
    @type t :: %__MODULE__{
            schema: list(Request.Schema.t()),
            covered: list(CoveredCase.t())
          }

    defstruct schema: nil,
              covered: []
  end

  @spec start_link(list(Request.Schema.t())) :: GenServer.on_start()
  def start_link(schema) do
    GenServer.start_link(__MODULE__, schema, name: __MODULE__)
  end

  @impl true
  def response_covered(covered_interaction) do
    GenServer.call(__MODULE__, {:response_covered, covered_interaction})
  end

  @spec coverage_report() :: Report.t()
  def coverage_report do
    GenServer.call(__MODULE__, :coverage_report)
  end

  @impl GenServer
  def init(schema) do
    {:ok, %State{schema: schema}}
  end

  @impl GenServer
  def handle_call({:response_covered, covered_case}, _from, %State{} = st) do
    new_st = %{st | covered: [covered_case | st.covered]}
    {:reply, :ok, new_st}
  end

  def handle_call(:coverage_report, _from, %State{} = st) do
    report = Report.new(st.schema, st.covered)
    {:reply, report, st}
  end
end
