defmodule Servy.Handler do

  @moduledoc "Handles HTTP request."

  alias Servy.Conv
  alias Servy.BearController

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

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bear, Lions and Tigers"}
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
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

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
