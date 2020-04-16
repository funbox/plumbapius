defmodule Plumbapius.PlugTest do
  use ExUnit.Case
  use Plug.Test

  alias FakePlugImplementation, as: Helper
  alias Plumbapius.Plug.Options.IncorrectSchemaError
  alias Plumbapius.Request.NotFoundError

  describe "test call method" do
    test "returns conn even for incorrect request but with Plumbapius.ignore command" do
      conn =
        conn(:get, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "application/json")
        |> Plumbapius.ignore()

      assert conn ==
               Plumbapius.Plug.call(
                 conn,
                 Helper.options(),
                 &Helper.handle_request_error/1,
                 &Helper.handle_response_error/1
               )
    end

    test "raise Request.NotFoundError when path is not specified for path due with method" do
      conn =
        conn(:get, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise NotFoundError,
                   ~s(request "GET": "/sessions" with content-type: "application/json" not found),
                   fn ->
                     Plumbapius.Plug.call(
                       conn,
                       Helper.options(),
                       &Helper.handle_request_error/1,
                       &Helper.handle_response_error/1
                     )
                   end
    end

    test "raise Request.NotFoundError when path is not specified for path due with content-type" do
      conn =
        conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "plain/text")

      assert_raise NotFoundError,
                   ~s(request "POST": "/sessions" with content-type: "plain/text" not found),
                   fn ->
                     Plumbapius.Plug.call(
                       conn,
                       Helper.options(),
                       &Helper.handle_request_error/1,
                       &Helper.handle_response_error/1
                     )
                   end
    end

    test "raise Request.NotFoundError when path is not specified for path due with no content-type specified" do
      conn =
        conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> delete_req_header("content-type")

      assert_raise NotFoundError,
                   ~s(request "POST": "/sessions" with content-type: nil not found),
                   fn ->
                     Plumbapius.Plug.call(
                       conn,
                       Helper.options(),
                       &Helper.handle_request_error/1,
                       &Helper.handle_response_error/1
                     )
                   end
    end

    test "raise Request.NotFoundError when path is not specified for path due no method specified" do
      conn =
        conn(nil, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise NotFoundError,
                   ~s(request "": "/sessions" with content-type: "application/json" not found),
                   fn ->
                     Plumbapius.Plug.call(
                       conn,
                       Helper.options(),
                       &Helper.handle_request_error/1,
                       &Helper.handle_response_error/1
                     )
                   end
    end

    test "raise Request.NotFoundError when path is not specified for path due with path" do
      conn =
        conn(:post, "/foo-bar", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise NotFoundError,
                   "request \"POST\": \"/foo-bar\" with content-type: \"application/json\" not found",
                   fn ->
                     Plumbapius.Plug.call(
                       conn,
                       Helper.options(),
                       &Helper.handle_request_error/1,
                       &Helper.handle_response_error/1
                     )
                   end
    end

    test "raise Helper.RequestHandlerRaiseError when pass incorrect params" do
      conn =
        conn(:post, "/sessions", %{"foo" => "bar", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise Helper.RequestHandlerRaiseError,
                   ~s(Plumpabius.RequestError: %Plumbapius.Request.ErrorDescription{body: %{"foo" => "bar", "password" => "admin"}, error: [{"Required property login was not present.", "#"}], method: "POST", path: "/sessions"}),
                   fn ->
                     Plumbapius.Plug.call(
                       conn,
                       Helper.options(),
                       &Helper.handle_request_error/1,
                       &Helper.handle_response_error/1
                     )
                   end
    end

    test "raise Helper.ResponseHandlerRaiseError when returns incorrect params" do
      conn = correct_conn_with_response(201, "{\"confirmation\": {\"foo\": \"bar\"}}")

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~s(Plumpabius.ResponseError: %Plumbapius.Response.ErrorDescription{body: "{\\"confirmation\\": {\\"foo\\": \\"bar\\"}}", error: "invalid", request: %{method: "POST", path: "/sessions"}, status: 201}),
                   fn ->
                     send_resp(conn)
                   end
    end

    test "raise Helper.ResponseHandlerRaiseError when returns incorrect status" do
      conn = correct_conn_with_response(123, ~s({"confirmation": {"id": "avaFqscDQWcAs"}}))

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~s(Plumpabius.ResponseError: %Plumbapius.Response.ErrorDescription{body: "{\\"confirmation\\": {\\"id\\": \\"avaFqscDQWcAs\\"}}", error: "invalid", request: %{method: "POST", path: "/sessions"}, status: 123}),
                   fn ->
                     send_resp(conn)
                   end
    end

    test "raise Helper.ResponseHandlerRaiseError when returns incorrect body" do
      conn = correct_conn_with_response(123, "qwe")

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~s(Plumpabius.ResponseError: %Plumbapius.Response.ErrorDescription{body: "qwe", error: {:invalid, "q", 0}, request: %{method: "POST", path: "/sessions"}, status: 123}),
                   fn ->
                     send_resp(conn)
                   end
    end

    test "returns without exceptions for empty response body" do
      conn = correct_conn_with_response(200, "")

      send_resp(conn)
    end

    test "returns without exceptions" do
      conn = correct_conn_with_response(201, "{\"confirmation\": {\"id\": \"afqWDXAcaWacW\"}}")

      send_resp(conn)
    end

    defp correct_conn_with_response(status, body) do
      conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
      |> put_req_header("content-type", "application/json")
      |> Plumbapius.Plug.call(
        Helper.options(),
        &Helper.handle_request_error/1,
        &Helper.handle_response_error/1
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
