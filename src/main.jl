include("socket.jl")

function main()
  socket = BatsimSocket()
  init_socket(socket)
  data = recv_message(socket)
  println(data)
  close_socket(socket)
end

main()
