require 'webrick'

server = WEBrick::HTTPServer.new Port: 8080

trap('INT') { server.shutdown }

server.mount_proc '/' do |req, res|
  res.body = "Hello, world!\nSee more at www.radovsky.com"
  res.content_type = 'text/text'
  res.status = 200
end

server.start