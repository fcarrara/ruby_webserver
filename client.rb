require 'socket'
require 'json'

class Client

  def initialize
    @host = "localhost"
    @port = 2000
    @path = ""
  end

  def send_request(request)
    # Using sockets
    socket = TCPSocket.open(@host, @port)
    socket.print(request)
    response = socket.read
    # Split response at first blank into headers and body
    headers, body = response.split("\r\n\r\n", 2)
    puts headers
    puts body

  end

  def init
    puts "Please select the request type: \n\n"
    puts "   1. GET"
    puts "   2. POST \n\n"
    input = gets.chomp
    
    print "Please enter the file name: "
    @path = gets.chomp
    
    if input == "1"
      request = "GET /#{@path} HTTP/1.0\r\n\r\n"

    else
      print "Please enter the viking's name: "
      name = gets.chomp
      print "Please enter the viking's email: "
      email = gets.chomp
      viking = { :viking => { :name => name, :email => email } }
      viking = viking.to_json
      request = "POST /#{@path} HTTP/1.0\r\n" +
                "Content-Type: application/x-www-form-urlencoded\r\n" +
                "Content-Length: #{viking.size}\r\n\n" +
                viking
    end

    send_request(request)

  end

end

client = Client.new
client.init

