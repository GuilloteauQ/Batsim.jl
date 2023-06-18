include("../job.jl")


mutable struct AcceptorScheduler
  batsim
  already_running_job_id
  waiting_queue

  AcceptorScheduler(batsim) = new(batsim, -1, [])
end

function start_job(sched, job)
  job.allocation = "1-$(job.requested_resources)"
  sched.already_running_job_id = job.job_id
  execute_job(sched.batsim, job)
end


function on_job_submission!(sched, job)
  if sched.already_running_job_id != -1
    push!(sched.waiting_queue, job)
  else
    start_job(sched, job)
  end
end

function on_job_completion!(sched, job)
  @assert job.job_id == sched.already_running_job_id
  sched.already_running_job_id = -1
  if length(sched.waiting_queue) > 0
    start_job(sched, pop!(sched.waiting_queue))
  end
end
