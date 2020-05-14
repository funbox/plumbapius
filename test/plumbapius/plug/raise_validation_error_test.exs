defmodule Plumbapius.Plug.RaiseValidationErrorTest do
  use ExUnit.Case

  alias Plumbapius.Plug.RaiseValidationError.RequestError
  alias Plumbapius.Plug.RaiseValidationError.ResponseError
  alias Plumbapius.Plug.RaiseValidationError
  alias FakePlugImplementation, as: Helper

  test "init delegates to base Plug and returns options" do
    init_options = [json_schema: File.read!("test/fixtures/correct_schema.json")]

    assert RaiseValidationError.init(init_options) == Helper.options()
  end

  test "raise RequestError when request invalid" do
    assert_raise RequestError,
                 ~r/Unexpected REQUEST/,
                 fn -> RaiseValidationError.call(:request_error, nil, FakePlug) end
  end

  test "raise ResponseError when response invalid" do
    assert_raise ResponseError,
                 ~r/Unexpected RESPONSE/,
                 fn -> RaiseValidationError.call(:response_error, nil, FakePlug) end
  end

  test "raise RequestError when both invalid" do
    assert_raise RequestError,
                 ~r/Unexpected REQUEST/,
                 fn -> RaiseValidationError.call(:both, nil, FakePlug) end
  end

  test "plug return call result" do
    assert RaiseValidationError.call(nil, nil, FakePlug) == {:ok, :called}
  end
end
