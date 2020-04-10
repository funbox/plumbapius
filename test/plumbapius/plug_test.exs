defmodule Plumbapius.PlugTest do
  use ExUnit.Case
  use Plug.Test

  defmodule Helper do
    defmodule RequestHandlerRaiseError do
      defexception message: "mock raise validation request error"
    end

    defmodule ResponseHandlerRaiseError do
      defexception message: "mock raise validation response error"
    end

    @options %Plumbapius.Plug.Options{
      schema: [
        %Plumbapius.Request.Schema{
          body: %ExJsonSchema.Schema.Root{
            custom_format_validator: nil,
            location: :root,
            refs: %{},
            schema: %{
              "$schema" => "http://json-schema.org/draft-04/schema#",
              "properties" => %{
                "login" => %{"type" => "string"},
                "password" => %{"type" => "string"}
              },
              "required" => ["login", "password"],
              "type" => "object"
            }
          },
          content_type: "application/json",
          method: "POST",
          path: ~r/\A\/sessions\z/,
          responses: [
            %Plumbapius.Response.Schema{
              body: %ExJsonSchema.Schema.Root{
                custom_format_validator: nil,
                location: :root,
                refs: %{},
                schema: %{}
              },
              content_type: "application/json",
              status: 401
            },
            %Plumbapius.Response.Schema{
              body: %ExJsonSchema.Schema.Root{
                custom_format_validator: nil,
                location: :root,
                refs: %{},
                schema: %{
                  "$schema" => "http://json-schema.org/draft-04/schema#",
                  "properties" => %{
                    "confirmation" => %{
                      "properties" => %{"id" => %{"type" => "string"}},
                      "required" => ["id"],
                      "type" => "object"
                    }
                  },
                  "type" => "object"
                }
              },
              content_type: "application/json",
              status: 201
            }
          ]
        }
      ]
    }

    def options, do: @options

    @spec handle_request_error(Plug.Conn.t(), any) :: none
    def handle_request_error(_, _), do: raise(RequestHandlerRaiseError)

    @spec handle_response_error(Plug.Conn.t(), any) :: none
    def handle_response_error(_, _), do: raise(ResponseHandlerRaiseError)
  end

  alias Plumbapius.Plug.Options.IncorrectSchemaError
  alias Plumbapius.Request.NotFoundError

  describe "test call method" do
    test "raise Request.NotFoundError when path is not specified for path due with method" do
      conn = conn(:get, "/sessions", %{"login" => "admin", "password" => "admin"})

      assert_raise NotFoundError, "request \"GET\": \"/sessions\" not found", fn ->
        Plumbapius.Plug.call(
          conn,
          Helper.options(),
          &Helper.handle_request_error/2,
          &Helper.handle_response_error/2
        )
      end
    end

    test "raise Request.NotFoundError when path is not specified for path due with path" do
      conn = conn(:post, "/foo-bar", %{"login" => "admin", "password" => "admin"})

      assert_raise NotFoundError, "request \"POST\": \"/foo-bar\" not found", fn ->
        Plumbapius.Plug.call(
          conn,
          Helper.options(),
          &Helper.handle_request_error/2,
          &Helper.handle_response_error/2
        )
      end
    end

    test "raise Helper.RequestHandlerRaiseError when pass incorrect params" do
      conn = conn(:post, "/sessions", %{"foo" => "bar", "password" => "admin"})

      assert_raise Helper.RequestHandlerRaiseError, "mock raise validation request error", fn ->
        Plumbapius.Plug.call(
          conn,
          Helper.options(),
          &Helper.handle_request_error/2,
          &Helper.handle_response_error/2
        )
      end
    end

    test "raise Helper.ResponseHandlerRaiseError when returns incorrect params" do
      conn = correct_conn_with_response(201, "{\"confirmation\": {\"foo\": \"bar\"}}")

      assert_raise Helper.ResponseHandlerRaiseError, "mock raise validation response error", fn ->
        send_resp(conn)
      end
    end

    test "raise Helper.ResponseHandlerRaiseError when returns incorrect status" do
      conn = correct_conn_with_response(123, "{\"confirmation\": {\"id\": \"avaFqscDQWcAs\"}}")

      assert_raise Helper.ResponseHandlerRaiseError, "mock raise validation response error", fn ->
        send_resp(conn)
      end
    end

    test "returns without exceptions" do
      conn = correct_conn_with_response(201, "{\"confirmation\": {\"id\": \"afqWDXAcaWacW\"}}")
      send_resp(conn)
    end

    @spec correct_conn_with_response(non_neg_integer, binary) :: Plug.Conn.t()
    def correct_conn_with_response(status, body) do
      conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
      |> Plumbapius.Plug.call(
        Helper.options(),
        &Helper.handle_request_error/2,
        &Helper.handle_response_error/2
      )
      |> resp(status, body)
    end
  end

  describe "test init method" do
    test "parse file which does not exist raise IncorrectSchemaError" do
      init_options = [apib_json_filepath: "incorrect/path/file.json"]

      assert_raise IncorrectSchemaError, "{:error, :enoent}", fn ->
        Plumbapius.Plug.init(init_options)
      end
    end

    test "parse file with incorrect json structure raise IncorrectSchemaError" do
      init_options = [apib_json_filepath: "test/fixtures/incorrect_schema.json"]

      assert_raise IncorrectSchemaError, "{:error, {:invalid, \"]\", 31}}", fn ->
        Plumbapius.Plug.init(init_options)
      end
    end

    test "parse correct json file" do
      init_options = [apib_json_filepath: "test/fixtures/correct_schema.json"]

      assert Plumbapius.Plug.init(init_options) == Helper.options()
    end
  end
end
