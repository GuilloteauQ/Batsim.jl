
@enum JobState UNKNOWN IN_SUBMISSON SUBMITTED RUNNING COMPLETED_SUCCESSFULLY COMPLETED_FAILED COMPLETED_WALLTIME_REACHED COMPLETED_KILLED REJECTED IN_KILLING

mutable struct Job
    job_id::Integer
    submit_time::Number
    requested_time::Number
    requested_resources::Integer
    profile::String
    starting_time
    finish_time
    job_state::JobState
    return_code
    profile_dict
    allocation
    metadata

    Job(job_id, submit_time, walltime, res, profile) = new(job_id, submit_time, walltime, res, profile, nothing, nothing, UNKNOWN, nothing, nothing, nothing, nothing)
end