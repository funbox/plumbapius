defmodule Plumbapius.Coverage.Report.MultiChoiceSchemaTest do
  use ExUnit.Case

  alias Plumbapius.Coverage.Report.MultiChoiceSchema
  alias Plumbapius.Request.Schema, as: RequestSchema
  alias Plumbapius.Response.Schema, as: ResponseSchema

  @one_of_schema %{
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

  @enum_schema %{
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

  describe "#multi_choices" do
    test "extracts multi choices and groups them by interaction" do
      request = %RequestSchema{
        method: "GET",
        path: "",
        original_path: "/some/path",
        responses: [],
        body: %{schema: @one_of_schema}
      }

      response = %ResponseSchema{
        status: 200,
        content_type: "",
        body: %{schema: @enum_schema}
      }

      interaction = {request, response}

      assert MultiChoiceSchema.multi_choices([interaction]) == %{
               interaction => [
                 {["root", "message"],
                  %{
                    "properties" => %{"textMessage" => %{"type" => "string"}},
                    "type" => "object"
                  }},
                 {["root", "message"],
                  %{
                    "properties" => %{"fileMessage" => %{"type" => "string"}},
                    "type" => "object"
                  }},
                 {["root", "message"], %{"enum" => ["textMessage"], "type" => "string"}},
                 {["root", "message"], %{"enum" => ["fileMessage"], "type" => "string"}}
               ]
             }
    end
  end

  describe "#new" do
    test "extracts oneOf choices from schema" do
      assert MultiChoiceSchema.new(@one_of_schema) == [
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

    test "extracts enum choices from schema" do
      assert MultiChoiceSchema.new(@enum_schema) == [
               {["root", "message"], %{"enum" => ["textMessage"], "type" => "string"}},
               {["root", "message"], %{"enum" => ["fileMessage"], "type" => "string"}}
             ]
    end
  end
end
