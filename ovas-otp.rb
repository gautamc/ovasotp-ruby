#!/usr/bin/env ruby

require 'socket'
require 'openssl'

socket = TCPSocket.new("127.0.0.1", "1241")
ssl_context = OpenSSL::SSL::SSLContext.new()
unless ssl_context.verify_mode
  warn "waring: peer certificate won't be verified this session."
  ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
end

sslsocket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
sslsocket.sync_close = true

sslsocket.connect

sslsocket.puts("< OTP/1.0 >")
buf = sslsocket.read(19)
print buf

user = $stdin.gets.chomp
sslsocket.puts(user)
buf = sslsocket.read(11)
print buf
passwd = $stdin.gets.chomp
sslsocket.puts(passwd)

puts "Connected to openVAS server... launching shell.."
while(1)
  print "openvas-rubyclient> "
  cmd = $stdin.gets.chomp
  
  if cmd =~ /^\s*attack\s+(\w+)/i
    
    sslsocket.puts("CLIENT <|> LONG_ATTACK <|>")
    sslsocket.puts( $1.length.to_s )
    # TODO: openvas-client-2.0.1/nessus/attack.c says - need to send by packets of 1024 bytes
    sslsocket.puts( $1 )
    buf = sslsocket.readpartial(200)
    puts buf
  end
  
  if cmd =~ /^\s*bye\s*/i
    break
  end
end

sslsocket.close
