include("../intervalset.jl")
include("../job.jl")

mutable struct FCFSScheduler
  batsim::Batsim
  open_jobs::Vector{Job}
  idle_machines::IntervalSet

  FCFSScheduler(batsim::Batsim) = new(batsim, [], IntervalSet([]))
end

function on_simulation_begins!(sched::FCFSScheduler)
  sched.idle_machines = IntervalSet([Interval(0, get_nb_compute_resources(sched.batsim) - 1)])
end

function schedule!(sched::FCFSScheduler)
  if length(sched.open_jobs) == 0
    return
  end

  index_current_job = 1
  nb_jobs = length(sched.open_jobs)

  while index_current_job <= nb_jobs
    job = sched.open_jobs[index_current_job]
    nb_res_req = job.requested_resources

    if nb_res_req <= length(sched.idle_machines)
      job.allocation = assign_resources!(sched, nb_res_req)
      index_current_job += 1
    else
      break
    end
  end
  execute_jobs(sched.batsim, sched.open_jobs[1:(index_current_job - 1)])
  sched.open_jobs = sched.open_jobs[index_current_job:nb_jobs]
  nothing
end

function assign_resources!(sched::FCFSScheduler, nb_res_req::Int64)::IntervalSet
  resources = find_spots(sched.idle_machines, nb_res_req)
  #sched.computing_machines |= resources
  sched.idle_machines -= resources
  resources
end

function on_job_completion!(sched::FCFSScheduler, job::Job)
  sched.idle_machines |= job.allocation
  nothing
end

function on_job_submission!(sched::FCFSScheduler, job::Job)
  if job.requested_resources > sched.batsim.nb_resources
    reject_jobs(sched.batsim, [job])
  else
    push!(sched.open_jobs, job)
    schedule!(sched)
  end
  nothing
end

on_no_more_events!(sched::FCFSScheduler) = schedule!(sched)
