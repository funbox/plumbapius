defmodule Plumbapius.Coverage.Report.MultiChoiceSchemaTest do
  use ExUnit.Case

  alias Plumbapius.Coverage.Report.MultiChoiceSchema

  describe "#new" do
    test "it extracts oneOf choices from schema" do
      schema = %{
        "type" => "object",
        "properties" => %{
          "root" => %{
            "type" => "object",
            "properties" => %{
              "message" => %{
                "type" => "object",
                "oneOf" => [
                  %{"properties" => %{"textMessage" => %{"type" => "string"}}},
                  %{"properties" => %{"fileMessage" => %{"type" => "string"}}}
                ]
              }
            }
          }
        }
      }

      assert MultiChoiceSchema.new(schema) == [
               {["root", "message"],
                %{
                  "properties" => %{"textMessage" => %{"type" => "string"}},
                  "type" => "object"
                }},
               {["root", "message"],
                %{
                  "properties" => %{"fileMessage" => %{"type" => "string"}},
                  "type" => "object"
                }}
             ]
    end

    test "it extracts enum choices from schema" do
      schema = %{
        "type" => "object",
        "properties" => %{
          "root" => %{
            "type" => "object",
            "properties" => %{
              "message" => %{
                "type" => "string",
                "enum" => [
                  "textMessage",
                  "fileMessage"
                ]
              }
            }
          }
        }
      }

      assert MultiChoiceSchema.new(schema) == [
               {["root", "message"], %{"enum" => ["textMessage"], "type" => "string"}},
               {["root", "message"], %{"enum" => ["fileMessage"], "type" => "string"}}
             ]
    end
  end
end
