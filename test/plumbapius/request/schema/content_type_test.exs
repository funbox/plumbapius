defmodule Plumbapius.Request.Schema.ContentTypeTest do
  use ExUnit.Case, async: true
  doctest Plumbapius.Request.Schema.ContentType
  alias Plumbapius.Request.Schema.ContentType

  describe "Plumbapius.Request.Schema.ContentType.to_regex/1" do
    test "when the content-type is null" do
      content_type = "null"
      assert ContentType.to_regex(content_type) == ~r/\Anull\z/
    end

    test "when the content-type parameter has a fixed value" do
      content_type = "multipart/mixed; boundary=boundary"
      assert ContentType.to_regex(content_type) == ~r/\Amultipart\/mixed;\ boundary=boundary\z/
    end

    test "when the content-type parameter has a variable" do
      content_type = "multipart/mixed; boundary={boundary}"
      assert ContentType.to_regex(content_type) == ~r/\Amultipart\/mixed;\ boundary=[^\s]+\z/
    end

    test "when the content-type has many variables replaces only parameter variable" do
      content_type = "{type}; {parameter}={value}"
      assert ContentType.to_regex(content_type) == ~r/\A{type};\ {parameter}=[^\s]+\z/
    end

    test "matches when the content-type is null" do
      content_type = ContentType.to_regex("null")
      assert_match("null", content_type)
    end

    test "matches when the content-type parameter has a fixed value" do
      content_type = ContentType.to_regex("multipart/mixed; boundary=boundary")
      assert_match("multipart/mixed; boundary=boundary", content_type)
    end

    test "matches when the content-type parameter has a variable" do
      content_type = ContentType.to_regex("multipart/mixed; boundary={boundary}")
      incorrect_content_type = "multipart/mixed; boundary=plug_conn test"

      request_content_types = [
        "multipart/mixed; boundary=plug_conn_test",
        "multipart/mixed; boundary=\"string\"",
        "multipart/mixed; boundary=\"----string\""
      ]

      refute String.match?(incorrect_content_type, content_type)
      assert_match(request_content_types, content_type)
    end
  end

  defp assert_match(content_types, regex_content_type) when is_list(content_types) do
    for content_type <- content_types do
      assert_match(content_type, regex_content_type)
    end
  end

  defp assert_match(content_type, regex_content_type) do
    assert String.match?(content_type, regex_content_type),
           inspect(content_type: content_type, regex_content_type: regex_content_type)
  end
end
