include("job.jl")

struct BatsimScheduler
  batsim
end


function on_job_submission(scheduler, job)
  reject_jobs(scheduler.batsim, [job])
end
