defmodule Plumbapius.ErrorFormatTest do
  use ExUnit.Case, async: true
  alias Plumbapius.ErrorFormat

  describe "#body" do
    test "converts to binary" do
      assert_convert_to_binary(&ErrorFormat.body/1)
    end
  end

  describe "#schema_error" do
    test "converts to binary" do
      assert_convert_to_binary(&ErrorFormat.schema_error/1)
    end
  end

  defp assert_convert_to_binary(function) do
    assert function.(10) == "10"
    assert function.(:atom) == "atom"
    assert function.(%{"test" => 10}) == "%{\"test\" => 10}"
    assert function.([10, 20, 40]) == <<10, 20, 40>>
    assert function.(["The symbol for pi is: ", ?π]) == "The symbol for pi is: , 960"
  end
end
