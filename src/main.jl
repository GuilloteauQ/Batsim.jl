include("batsim.jl")
include("schedulers/fcfs.jl")

function main()
  batsim = Batsim()
  sched = FCFSScheduler(batsim)
  set_scheduler!(batsim, sched)
  start(batsim)
end

main()
