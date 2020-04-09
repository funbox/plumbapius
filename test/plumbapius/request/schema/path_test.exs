defmodule Plumbapius.Request.Schema.PathTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request.Schema.Path
  alias Plumbapius.Request.Schema.Path

  describe "Plumbapius.Request.Schema.Path.to_regex/1" do
    test "when the path does not have a resource id" do
      path_without_id = "/users"
      assert Path.to_regex(path_without_id) == ~r/\A\/users\z/
    end

    test "when the path has a resource id" do
      path_with_id = "/users/{id}"
      assert Path.to_regex(path_with_id) == ~r/\A\/users\/[^&=\/]+\z/
    end

    test "when the path has many resource id" do
      path_with_many_id = "/users/{id}/zones/{zone_id}"
      assert Path.to_regex(path_with_many_id) == ~r/\A\/users\/[^&=\/]+\/zones\/[^&=\/]+\z/
    end
  end
end
