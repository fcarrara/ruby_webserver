require 'socket'
require 'json'

class Server

  CONTENT_TYPE = { 
  "html" => "text/html",
  "txt"  => "text/plain",
  "png"  => "image/png",
  "jpg"  => "image/jpeg"
  }

  def initialize
    @server = TCPServer.open(2000)
  end

  def get_content_type(path)
    ext = path.split(".").last
    CONTENT_TYPE.fetch(ext)
  end

  def process_post_method(client)
    headers = {}

    while line = client.gets    # Collect HTTP headers
      break if line == "\n"  # Blank line means no more headers
      headers[line.split(":")[0]] = line.split(":")[1].strip # Hash headers by type
    end
  
    # Read the POST data as specified in the header
    params = JSON.parse(client.read(headers["Content-Length"].to_i))
    params.each
    data = "<li>Name: #{params["viking"]["name"]}</li><li>Email: #{params["viking"]["email"]}</li>"
  end

  def start
    loop {

      client = @server.accept
      method, path = client.gets.split # get from first line e.g: "GET / HTTP/1.1\r\n"
      path = path[1..-1]

      if File.exist?(path)
        file = File.read(path)
        client.print "HTTP/1.1 200 OK\r\n" + 
                     "Content-Type: #{get_content_type(path)}\r\n" +
                     "Content-Length: #{file.size}\r\n" + 
                     "Connection: close\r\n\r\n"

        if method == "POST"
          file.gsub!("<%= yield %>", process_post_method(client))
        end

        client.print(file)
        
      else
        message = "File not found\n"

        client.print "HTTP/1.1 404 Not Found\r\n" + 
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: #{message.size}\r\n" + 
                     "Connection: close\r\n\r\n"

        client.print message

      end

      client.close

    } #end of loop

  end
end


server = Server.new
server.start

