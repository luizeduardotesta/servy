defmodule Servy.Handler do
  def handler(request) do
  end

  def parse(request) do
    # TODO: Parse the request string into a map:
    conv = %{method: "GET", path: "/wildthings", resp_body: "" }
  end

  def route(conv) do
    # TODO: Create a new map that also has the response body:
    conv = %{method: "GET", path: "/wildthings", resp_body: "Bear, Lions and Tigers" }
  end

  def format_response(conv) do
    # TODO: Use values in the map to create an HTTP response string:
  end
end

request = """
GET /wildthings HTTP/1.1
Host: exemple.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

expected_response = """
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 20

Bears, Lions, Tigers
"""

response = Servy.Handler.handler(request)

IO.puts(response)