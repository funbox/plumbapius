defmodule Plumbapius.Request.Schema.PathTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request.Schema.Path
  alias Plumbapius.Request.Schema.Path

  describe "#to_regex" do
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

    test "matches when the path has many resource id" do
      path_with_many_id = "/users/{id}/zones/{zone_id}"
      path = Path.to_regex(path_with_many_id)
      request_path = "/users/acSCSDRfeW/zones/vdsDDWQF"
      incorrect_path = "/users/acSCSDRfeW/zones/vdsDDWQF/"

      assert String.match?(request_path, path)
      refute String.match?(incorrect_path, path)
    end

    test "matches when the path has a resource id" do
      path_with_id = "/users/{id}/profile"
      path = Path.to_regex(path_with_id)
      request_path = "/users/cScwDSDE/profile"
      incorrect_path = "/users/cScwDSDE/profile/"

      assert String.match?(request_path, path)
      refute String.match?(incorrect_path, path)
    end

    test "matches when the path has many resource id and close with no resource" do
      path_with_many_id = "/users/{id}/zones/{zone_id}/info"
      path = Path.to_regex(path_with_many_id)
      request_path = "/users/acSCSDRfeW/zones/vdsDDWQF/info"
      incorrect_path = "/users/acSCSDRfeW/zones/vdsDDWQF/info/"

      assert String.match?(request_path, path)
      refute String.match?(incorrect_path, path)
    end

    test "matches when the path has a resource only" do
      path_with_many_id = "/{id}"
      path = Path.to_regex(path_with_many_id)
      request_path = "/acSCSDRfeW"
      incorrect_path = "/acSCSDRfeW/"

      assert String.match?(request_path, path)
      refute String.match?(incorrect_path, path)
    end

    test "escape url symbols" do
      path_with_many_id = "/{id}.+"
      path = Path.to_regex(path_with_many_id)

      request_path = "/acSCSDRfeW.+"
      incorrect_path = "/acSCSDRfeW/foo/bar"

      assert String.match?(request_path, path)
      refute String.match?(incorrect_path, path)
    end
  end
end
