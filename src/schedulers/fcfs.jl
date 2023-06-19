include("../intervalset.jl")
include("../job.jl")

mutable struct FCFSScheduler
  batsim
  open_jobs::Vector{Job}
  computing_machines
  idle_machines

  FCFSScheduler(batsim) = new(batsim, [], IntervalSet([]), IntervalSet([]))
end

function on_simulation_begins!(sched)
  sched.idle_machines = IntervalSet([Interval(0, get_nb_compute_resources(sched.batsim) - 1)])
end

function schedule!(sched)
  if length(sched.open_jobs) == 0
    return
  end

  # scheduled_jobs = []
  index_current_job = 1
  nb_jobs = length(sched.open_jobs)

  while index_current_job <= nb_jobs
    job = sched.open_jobs[index_current_job]
    nb_res_req = job.requested_resources

    if nb_res_req <= length(sched.idle_machines)
      resources = find_spots(sched.idle_machines, nb_res_req)
      job.allocation = resources
      # push!(scheduled_jobs, job)

      sched.computing_machines |= resources
      sched.idle_machines -= resources
      # popfirst!(sched.open_jobs)
      index_current_job += 1
    else
      break
    end
  end
  # execute_jobs(sched.batsim, scheduled_jobs)
  execute_jobs(sched.batsim, sched.open_jobs[1:(index_current_job - 1)])
  sched.open_jobs = sched.open_jobs[index_current_job:nb_jobs]

  nothing
end


function on_job_completion!(sched, job)
  sched.idle_machines |= job.allocation
  sched.computing_machines -= job.allocation
end

function on_job_submission!(sched, job)
  if job.requested_resources > sched.batsim.nb_resources
    reject_jobs(sched.batsim, [job])
  else
    push!(sched.open_jobs, job)
    schedule!(sched)
  end
end

on_no_more_events!(sched) = schedule!(sched)
