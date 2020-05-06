defmodule Plumbapius.PlugTest do
  use ExUnit.Case
  use Plug.Test

  alias FakePlugImplementation, as: Helper
  alias Plumbapius.Plug.Options.IncorrectSchemaError
  alias Plumbapius.Request.{NotFoundError, UnknownContentTypeError, NoContentTypeError}
  alias Plumbapius.AbstractPlug

  describe "test call method" do
    test "returns conn even for incorrect request when Plumbapius.ignore() is used" do
      conn =
        conn(:get, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "application/json")
        |> Plumbapius.ignore()

      assert conn == call_plug(conn)
    end

    test "raises error when path exists in schema but method is wrong" do
      conn = conn(:get, "/sessions", %{"login" => "admin", "password" => "admin"})

      assert_raise NotFoundError, fn -> call_plug(conn) end
    end

    test "raises error when content-type header does not match specified in schema" do
      conn =
        conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "plain/text")

      assert_raise UnknownContentTypeError, fn -> call_plug(conn) end
    end

    test "raises error when content-type header is missing in post request" do
      conn = conn(:post, "/sessions")
      assert_raise NoContentTypeError, fn -> call_plug(conn) end
    end

    test "raises error when method is not specified" do
      conn = conn(nil, "/sessions", %{"login" => "admin", "password" => "admin"})
      assert_raise NotFoundError, fn -> call_plug(conn) end
    end

    test "raises error when path is not present in schema" do
      conn =
        conn(:post, "/foo-bar", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise NotFoundError, fn -> call_plug(conn) end
    end

    test "raises error when request params are incorrect" do
      conn =
        conn(:post, "/sessions", %{"foo" => "bar", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise Helper.RequestHandlerRaiseError, fn -> call_plug(conn) end
    end

    test "raises error when response has incorrect body params" do
      conn = post_request(201, "{\"confirmation\": {\"foo\": \"bar\"}}")

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~s(Plumpabius.ResponseError: %Plumbapius.Response.ErrorDescription{body: "{\\"confirmation\\": {\\"foo\\": \\"bar\\"}}", error: "invalid", request: %{method: "POST", path: "/sessions"}, status: 201}),
                   fn -> send_resp(conn) end
    end

    test "raises error when response returns incorrect status" do
      conn = post_request(123, ~s({"confirmation": {"id": "avaFqscDQWcAs"}}))

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~s(Plumpabius.ResponseError: %Plumbapius.Response.ErrorDescription{body: "{\\"confirmation\\": {\\"id\\": \\"avaFqscDQWcAs\\"}}", error: "invalid", request: %{method: "POST", path: "/sessions"}, status: 123}),
                   fn -> send_resp(conn) end
    end

    test "raises error when response returns incorrect json" do
      conn = post_request(123, "qwe")
      assert_raise Helper.ResponseHandlerRaiseError, fn -> send_resp(conn) end
    end

    test "returns without exceptions for empty response body" do
      conn = post_request(200, "")
      send_resp(conn)
    end

    test "returns without exceptions for post requests" do
      conn = post_request(201, "{\"confirmation\": {\"id\": \"afqWDXAcaWacW\"}}")
      send_resp(conn)
    end

    test "returns without exceptions for get requests" do
      conn =
        conn(:get, "/users")
        |> call_plug()
        |> resp(200, "{}")

      send_resp(conn)
    end

    defp post_request(status, body) do
      conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
      |> put_req_header("content-type", "application/json")
      |> call_plug()
      |> resp(status, body)
    end
  end

  describe "test init method" do
    test "parse file with incorrect json structure raise IncorrectSchemaError" do
      init_options = [json_schema: File.read!("test/fixtures/incorrect_schema.json")]
      assert_raise IncorrectSchemaError, fn -> AbstractPlug.init(init_options) end
    end

    test "parse correct json file" do
      init_options = [json_schema: File.read!("test/fixtures/correct_schema.json")]
      assert AbstractPlug.init(init_options) == Helper.options()
    end
  end

  def call_plug(conn) do
    AbstractPlug.call(
      conn,
      Helper.options(),
      &Helper.handle_request_error/1,
      &Helper.handle_response_error/1
    )
  end
end
