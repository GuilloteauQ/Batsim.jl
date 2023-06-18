include("../intervalset.jl")

mutable struct FCFSScheduler
  batsim
  open_jobs
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

  scheduled_jobs = []

  while length(sched.open_jobs) > 0
    job = sched.open_jobs[1]
    nb_res_req = job.requested_resources

    if nb_res_req <= length(sched.idle_machines)
      resources = find_spots(sched.idle_machines, nb_res_req)
      job.allocation = resources
      push!(scheduled_jobs, job)

      sched.computing_machines |= resources
      sched.idle_machines -= resources
      popfirst!(sched.open_jobs)
    else
      break
    end
  end

  execute_jobs(sched.batsim, scheduled_jobs)
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
