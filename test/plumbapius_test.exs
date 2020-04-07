defmodule PlumbapiusTest do
  use ExUnit.Case
  doctest Plumbapius

  test "greets the world" do
    assert Plumbapius.hello() == :world
  end
end
