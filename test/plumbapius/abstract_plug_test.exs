defmodule Plumbapius.AbstractPlugTest do
  use ExUnit.Case
  use Plug.Test

  alias FakePlugImplementation, as: Helper
  alias Plumbapius.Plug.Options.IncorrectSchemaError
  alias Plumbapius.AbstractPlug
  alias Plumbapius.Coverage.CoverageTracker.CoveredCase

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

      assert_raise Helper.RequestHandlerRaiseError, ~r/Request.NotFoundError/, fn -> call_plug(conn) end
    end

    test "raises error when content-type header does not match specified in schema" do
      conn =
        conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "plain/text")

      assert_raise Helper.RequestHandlerRaiseError, ~r/Request.UnknownContentTypeError/, fn -> call_plug(conn) end
    end

    test "raises error when content-type header is missing in post request" do
      conn = conn(:post, "/sessions")
      assert_raise Helper.RequestHandlerRaiseError, ~r/Request.NoContentTypeError/, fn -> call_plug(conn) end
    end

    test "raises error when method is not specified" do
      conn = conn(nil, "/sessions", %{"login" => "admin", "password" => "admin"})
      assert_raise Helper.RequestHandlerRaiseError, ~r/Request.NotFoundError/, fn -> call_plug(conn) end
    end

    test "raises error when path is not present in schema" do
      conn =
        conn(:post, "/foo-bar", %{"login" => "admin", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise Helper.RequestHandlerRaiseError, ~r/Request.NotFoundError/, fn -> call_plug(conn) end
    end

    test "raises error when request params are incorrect" do
      conn =
        conn(:post, "/sessions", %{"foo" => "bar", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      assert_raise Helper.RequestHandlerRaiseError, fn -> call_plug(conn) end
    end

    test "raises error when response has incorrect body params" do
      conn =
        post_request(201, "{\"confirmation\": {\"foo\": \"bar\"}}")
        |> put_resp_header("content-type", "application/json")

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~r/no_such_response_in_schema/,
                   fn -> send_resp(conn) end
    end

    test "raises error when response returns incorrect status" do
      conn =
        post_request(123, ~s({"confirmation": {"id": "avaFqscDQWcAs"}}))
        |> put_resp_header("content-type", "application/json")

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~r/no_such_response_in_schema/,
                   fn -> send_resp(conn) end
    end

    test "raises error when response has exception" do
      conn =
        post_request(500, ~s({"confirmation": {"id": "avaFqscDQWcAs"}}))
        |> assign(:reason, %RuntimeError{})
        |> assign(:stack, [])

      assert_raise Helper.ResponseHandlerRaiseError,
                   ~r/RuntimeError/,
                   fn -> send_resp(conn) end
    end

    test "raises error when response returns incorrect json" do
      conn =
        post_request(123, "{}")
        |> put_resp_header("content-type", "application/json")

      assert_raise Helper.ResponseHandlerRaiseError, fn -> send_resp(conn) end
    end

    test "raises error when response content-type header does not match specified in schema" do
      conn =
        post_request(201, ~s({"confirmation": {"id": "avaFqscDQWcAs"}}))
        |> put_resp_header("content-type", "text/plane")

      assert_raise Helper.ResponseHandlerRaiseError, fn -> send_resp(conn) end
    end

    test "raises error when response content-type header is missing" do
      conn = post_request(201, ~s({"confirmation": {"id": "avaFqscDQWcAs"}}))

      assert_raise Helper.ResponseHandlerRaiseError, fn -> send_resp(conn) end
    end

    test "returns without exceptions for empty response body" do
      conn =
        post_request(200, "")
        |> put_resp_header("content-type", "application/json")

      send_resp(conn)
    end

    test "returns without exceptions for post requests" do
      conn =
        post_request(201, "{\"confirmation\": {\"id\": \"afqWDXAcaWacW\"}}")
        |> put_resp_header("content-type", "application/json")

      send_resp(conn)
    end

    test "returns without exceptions for get requests" do
      conn =
        conn(:get, "/users")
        |> call_plug()
        |> resp(200, "{}")
        |> put_resp_header("content-type", "application/json")

      send_resp(conn)
    end

    test "calls coverage tracker" do
      conn =
        conn(:get, "/users")
        |> call_plug()
        |> resp(200, "{}")
        |> put_resp_header("content-type", "application/json")

      send_resp(conn)

      assert_received({:response_covered_called, %CoveredCase{}})
    end

    test "allows handle_request_error callback to modify conn" do
      conn =
        conn(:post, "/sessions", %{"foo" => "bar", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      new_conn =
        call_plug(conn, fn _error, conn -> Plug.Conn.assign(conn, :modified, true) end, fn _error, conn -> conn end)

      assert new_conn.assigns[:modified]
    end

    test "allows handle_request_error callback to send its own response" do
      conn =
        conn(:post, "/sessions", %{"foo" => "bar", "password" => "admin"})
        |> put_req_header("content-type", "application/json")

      new_conn =
        call_plug(
          conn,
          fn _error, conn ->
            send_resp(conn, 200, "{}")
          end,
          fn _error, conn -> conn end
        )

      assert new_conn.status == 200
    end

    test "allows handle_response_error callback to modify conn" do
      new_conn =
        post_request(404, "{}", fn _error, conn -> conn end, fn _error, conn ->
          Plug.Conn.assign(conn, :modified, true)
        end)
        |> send_resp()

      assert new_conn.assigns[:modified]
    end

    defp post_request(
           status,
           resp_body,
           request_handler \\ &Helper.handle_request_error/2,
           response_handler \\ &Helper.handle_response_error/2
         ) do
      conn(:post, "/sessions", %{"login" => "admin", "password" => "admin"})
      |> put_req_header("content-type", "application/json")
      |> call_plug(request_handler, response_handler)
      |> resp(status, resp_body)
    end
  end

  describe "test init method" do
    test "parses file with incorrect json structure raise IncorrectSchemaError" do
      init_options = [json_schema: File.read!("test/fixtures/incorrect_schema.json")]
      assert_raise IncorrectSchemaError, fn -> AbstractPlug.init(init_options) end
    end

    test "parses correct json file" do
      init_options = [json_schema: File.read!("test/fixtures/correct_schema.json")]
      assert AbstractPlug.init(init_options).schema == Helper.options().schema
    end
  end

  defp call_plug(
         conn,
         request_handler \\ &Helper.handle_request_error/2,
         response_handler \\ &Helper.handle_response_error/2
       ) do
    AbstractPlug.call(
      conn,
      Helper.options(),
      request_handler,
      response_handler
    )
  end
end
