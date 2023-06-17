include("socket.jl")
include("batsim.jl")
include("batsim_scheduler.jl")

function main()
  batsim = Batsim()
  init_batsim(batsim)
  bat_sched = BatsimScheduler(batsim)
  set_scheduler!(batsim, bat_sched)

  while true
    next_event!(batsim)
    println("recv")
  end

  close_socket(batsim.socket)

end

main()
