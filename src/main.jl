include("socket.jl")
include("batsim.jl")

function main()
  # socket = BatsimSocket()
  # init_socket(socket)
  # data = recv_message(socket)
  # println(data)
  # close_socket(socket)

  batsim = Batsim()
  init_batsim(batsim)
  while true
    next_event!(batsim)
    println("recv")
  end

  close_socket(batsim.socket)

end

main()
