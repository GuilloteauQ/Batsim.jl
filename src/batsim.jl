include("socket.jl")
include("job.jl")

# Should this just be a dict ?
mutable struct JobStats
    nb_jobs_submitted_from_batsim
    nb_jobs_submitted_from_scheduler
    nb_jobs_submitted
    nb_jobs_killed
    nb_jobs_rejected
    nb_jobs_scheduled
    nb_jobs_in_submission
    nb_jobs_completed
    nb_jobs_successful
    nb_jobs_failed
    nb_jobs_timeout

    # Init all at 0
    JobStats() = new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

mutable struct Batsim
    # jobs::Dict
    # job_stats::JobStats
    socket::BatsimSocket
    current_time    
    simulation_is_running::Bool
    nb_resources
    profiles
    workloads
    jobs

    Batsim() = new(BatsimSocket(), 0.0, false, 0, nothing, nothing, nothing)
end

function init_batsim(batsim)
    init_socket(batsim.socket)
    batsim.jobs = Dict()
end


function time(batsim)
    batsim.current_time
end

function next_event!(batsim)
    message = recv_message(batsim.socket)
    batsim.current_time = message["now"]
    
    for event in message["events"]
        event_type = event["type"]
        println("EVENT: $event_type")
        if event_type == "SIMULATION_BEGINS"
            manage_event_simulation_begins!(batsim, event["data"])
        elseif event_type == "SIMULATION_ENDS"
            manage_event_simulation_ends!(batsim)
        elseif event_type == "JOB_SUBMITTED"
            manage_event_job_submitted!(batsim, event["data"])
        elseif event_type == "NOTIFY"
            manage_event_notify!(batsim, event["data"])
        end
    end

    data = Dict("now" => time(batsim), "events" => [])
    send_message(batsim.socket, data)  
end

function manage_event_notify!(batsim, data)
    # TODO
    if data["type"] == "no_more_static_job_to_submit"
        println("no more job to submit")
    end
end

function manage_event_job_submitted!(batsim, data)
    job_id = data["job_id"]
    job_data = data["job"]
    new_job = Job(job_id, job_data["subtime"], job_data["walltime"], job_data["res"], job_data["profile"])
    # TODO store profile if new
    batsim.jobs[job_id] = new_job

    # TODO notify the sched
end

function manage_event_simulation_begins!(batsim, data)
    # TODO continue
    @assert !batsim.simulation_is_running
    batsim.simulation_is_running = true
    batsim.nb_resources = data["nb_resources"]
    batsim.workloads = data["workloads"]
    batsim.profiles = data["profiles"]

    # TODO notify the sched
end

function manage_event_simulation_ends!(batsim)
    @assert batsim.simulation_is_running
    batsim.simulation_is_running = false
end


