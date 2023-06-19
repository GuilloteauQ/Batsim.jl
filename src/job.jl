include("intervalset.jl")

@enum JobState UNKNOWN IN_SUBMISSION SUBMITTED RUNNING COMPLETED_SUCCESSFULLY COMPLETED_FAILED COMPLETED_WALLTIME_REACHED COMPLETED_KILLED REJECTED IN_KILLING

mutable struct Job
    job_id::String
    submit_time::Number
    requested_time::Number
    requested_resources::Integer
    profile::String
    starting_time::Float64
    finish_time::Float64
    job_state::JobState
    return_code
    profile_dict
    allocation::IntervalSet
    metadata

    Job(job_id, submit_time, walltime, res, profile) = new(job_id, submit_time, walltime, res, profile, 0.0, 0.0, SUBMITTED, nothing, nothing, IntervalSet([]), nothing)
end