defmodule Plumbapius.Plug.RaiseValidationErrorTest do
  use ExUnit.Case

  alias Plumbapius.Plug.RaiseValidationError.RequestError
  alias Plumbapius.Plug.RaiseValidationError.ResponseError
  alias Plumbapius.Plug.RaiseValidationError

  test "raise RequestError when request invalid" do
    assert_raise RequestError,
                 "Plumpabius.RequestError: %{body: %{\"foo\" => \"bar\"}, error: [{\"Type mismatch. Expected Number but got String.\", \"#/msisdn\"}], method: \"get\", path: \"/fake/path\"}",
                 fn -> RaiseValidationError.call(:request_error, nil, FakePlug) end
  end

  test "raise ResponseError when response invalid" do
    assert_raise ResponseError,
                 "Plumpabius.ResponseError: %{body: %{\"bar\" => \"foo\"}, error: \"invalid\", request: %{method: \"get\", path: \"/fake/path\"}, status: 200}",
                 fn -> RaiseValidationError.call(:response_error, nil, FakePlug) end
  end

  test "raise RequestError when both invalid" do
    assert_raise RequestError,
                 "Plumpabius.RequestError: %{body: %{\"foo\" => \"bar\"}, error: [{\"Type mismatch. Expected Number but got String.\", \"#/msisdn\"}], method: \"get\", path: \"/fake/path\"}",
                 fn -> RaiseValidationError.call(nil, nil, FakePlug) end
  end
end
