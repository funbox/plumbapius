defmodule Plumbapius.Plug.RaiseValidationErrorTest do
  use ExUnit.Case

  alias Plumbapius.Plug.RaiseValidationError.RequestError
  alias Plumbapius.Plug.RaiseValidationError.ResponseError
  alias Plumbapius.Plug.RaiseValidationError
  alias FakePlugImplementation, as: Helper

  test "init delegates to base Plug and returns options" do
    init_options = [apib_json_filepath: "test/fixtures/correct_schema.json"]

    assert RaiseValidationError.init(init_options) == Helper.options()
  end

  test "raise RequestError when request invalid" do
    assert_raise RequestError,
                 ~s(Plumpabius.RequestError: %Plumbapius.Request.ErrorDescription{body: %{"foo" => "bar"}, error: [{"Type mismatch. Expected Number but got String.", "#/msisdn"}], method: "get", path: "/fake/path"}),
                 fn -> RaiseValidationError.call(:request_error, nil, FakePlug) end
  end

  test "raise ResponseError when response invalid" do
    assert_raise ResponseError,
                 ~s(Plumpabius.ResponseError: %Plumbapius.Response.ErrorDescription{body: ["{", "foo", ":", "bar", "}"], error: "invalid", request: %{method: "get", path: "/fake/path"}, status: 200}),
                 fn -> RaiseValidationError.call(:response_error, nil, FakePlug) end
  end

  test "raise RequestError when both invalid" do
    assert_raise RequestError,
                 ~s(Plumpabius.RequestError: %Plumbapius.Request.ErrorDescription{body: %{"foo" => "bar"}, error: [{"Type mismatch. Expected Number but got String.", "#/msisdn"}], method: "get", path: "/fake/path"}),
                 fn -> RaiseValidationError.call(:both, nil, FakePlug) end
  end

  test "plug return call result" do
    assert RaiseValidationError.call(nil, nil, FakePlug) == {:ok, :called}
  end
end
