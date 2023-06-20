include("batsim.jl")
include("schedulers/fcfs.jl")
# using Profile
# using ProfileSVG

function main()
  batsim = Batsim()
  sched = FCFSScheduler(batsim)
  set_scheduler!(batsim, sched)

  # @profview start(batsim)
  start(batsim)
  # ProfileSVG.save("prof.svg", timeunit=:ms, maxdepth=50)
end

main()
