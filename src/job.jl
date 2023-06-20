include("intervalset.jl")

@enum JobState UNKNOWN IN_SUBMISSION SUBMITTED RUNNING COMPLETED_SUCCESSFULLY COMPLETED_FAILED COMPLETED_WALLTIME_REACHED COMPLETED_KILLED REJECTED IN_KILLING

mutable struct Job
    job_id::String
    submit_time::Float64
    requested_time::Int64
    requested_resources::Int64
    profile::String
    starting_time::Float64
    finish_time::Float64
    job_state::JobState
    return_code::Any
    profile_dict::Any
    allocation::IntervalSet
    metadata::Any

    Job(job_id::String, submit_time::Float64, walltime::Int64, res::Int64, profile::String) = new(job_id, submit_time, walltime, res, profile, 0.0, 0.0, SUBMITTED, nothing, nothing, IntervalSet([]), nothing)
end