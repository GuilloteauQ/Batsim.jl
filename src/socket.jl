using ZMQ
using JSON

struct BatsimSocket
  address
  socket

  BatsimSocket(address) = new(address, ZMQ.Socket(ZMQ.REP))
  BatsimSocket() = new("tcp://127.0.0.1:28000", ZMQ.Socket(ZMQ.REP))
end

function init_socket(socket)
  ZMQ.bind(socket.socket, socket.address)
end

function close_socket(socket)
  ZMQ.close(socket.socket)
end

function recv_message_string(socket::BatsimSocket)::String
  ZMQ.recv(socket.socket, String)
end

function recv_message(socket)
  JSON.parse(recv_message_string(socket))
end

function send_message(socket, message::String)
  ZMQ.send(socket.socket, message)
end

function send_message(socket, message::Dict)
  send_message(socket, JSON.json(message))
end
