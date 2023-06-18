include("../job.jl")

struct RejectorScheduler
  batsim
end


function on_job_submission!(scheduler, job)
  reject_jobs(scheduler.batsim, [job])
end
