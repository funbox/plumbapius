defmodule Plumbapius.ContentTypeTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.ContentType
  alias Plumbapius.ContentType

  describe "#convert_for_schema" do
    test "when the content-type is null" do
      content_type = "null"
      assert ContentType.convert_for_schema(content_type) == "null"
    end

    test "when the content-type has many variables replaces only parameter variable" do
      content_type = "{type}; {parameter}={value}"
      assert ContentType.convert_for_schema(content_type) == ~r/\A{type}; {parameter}=[^\s]+\z/
    end

    test "matches when the content-type is null" do
      content_type = ContentType.convert_for_schema("null")
      assert_match("null", content_type)
    end

    test "matches when the content-type parameter has a fixed value" do
      content_type = ContentType.convert_for_schema("multipart/mixed; boundary=boundary")
      assert_match("multipart/mixed; boundary=boundary", content_type)
    end

    test "matches when the content-type parameter has a variable" do
      content_type = ContentType.convert_for_schema("multipart/mixed; boundary={boundary}")
      assert_match("multipart/mixed; boundary=\"----string\"", content_type)
    end
  end

  describe "#match?" do
    test "any_content_type always matches" do
      assert ContentType.match?(nil, :any_content_type)
    end

    test "never matches missing content type" do
      refute ContentType.match?(nil, nil)
    end

    test "matches when content type is fixed" do
      assert ContentType.match?("application/json", "application/json")
      refute ContentType.match?("doge/dummy", "application/json")

      assert ContentType.match?("application/json", ~r/\Aapplication\/json\z/)
      refute ContentType.match?("doge/dummy", ~r/\Aapplication\/json\z/)
    end

    test "matches when content type has a variable" do
      regex = ~r/\Amultipart\/mixed; boundary=[^\s]+\z/

      assert ContentType.match?("multipart/mixed; boundary=plug_conn_test", regex)
      refute ContentType.match?("multipart/mixed; boundary=plug_conn test", regex)
    end

    test "ignores directives if no directives are defined in schema" do
      assert ContentType.match?("application/json; charset=utf-8", "application/json")
      refute ContentType.match?("application/other; charset=utf-8", "application/json")
    end

    test "does not ignore directives if directives are defined in schema" do
      assert ContentType.match?("application/json; charset=utf-8", "application/json; charset=utf-8")
      refute ContentType.match?("application/json; charset=cp1251", "application/json; charset=koi8-r")
    end
  end

  defp assert_match(content_type, schema_content_type) do
    assert ContentType.match?(content_type, schema_content_type),
           inspect(content_type: content_type, schema_content_type: schema_content_type)
  end
end
