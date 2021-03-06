defmodule Servy.Handler do

  @moduledoc "Handles HTTP request."

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins
  import Servy.Parser

  @doc "Transforms the request into a response."
  def handler(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    sensor_data = Servy.SensorServer.get_sensor_data()

    %{ conv | status: 200, resp_body: inspect sensor_data}
  end

  def route(%Conv{ method: "GET", path: "/kaboom"}) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Awake!" }
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bear, Lions and Tigers"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv)  do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv)  do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv)  do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  # name=Ballo&type=Brown
  def route(%Conv{method: "POST", path: "/bears"} = conv)  do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv)  do
      @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "no #{path} here!"}
  end

  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: exemple.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handler(request)

IO.puts response

request = """
GET /Bears HTTP/1.1
Host: exemple.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handler(request)

IO.puts response

request = """
GET /Bears/1 HTTP/1.1
Host: exemple.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-from-urlencoded
Content-Lenght: 21

name=Ballo&type=Brown
"""

response = Servy.Handler.handler(request)

IO.puts response

request = """
GET /Bigfoot HTTP/1.1
Host: exemple.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handler(request)

IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: exemple.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handler(request)

IO.puts response

request = """
GET /about HTTP/1.1
Host: exemple.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handler(request)

IO.puts response
