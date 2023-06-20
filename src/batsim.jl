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
    current_time::Float64    
    simulation_is_running::Bool
    nb_resources
    profiles
    workloads
    jobs::Dict{String, Job}
    scheduler
    events_to_send

    Batsim() = new(BatsimSocket(), 0.0, false, 0, nothing, nothing, Dict(), nothing, [])
end

get_nb_compute_resources(batsim) = batsim.nb_resources

function init_batsim(batsim)
    init_socket(batsim.socket)
    batsim.jobs = Dict()
end

function set_scheduler!(batsim, sched)
    batsim.scheduler = sched
end

function time(batsim)::Float64
    batsim.current_time
end

function start(batsim)
    init_batsim(batsim)
    done_conversing = false
    while !done_conversing
        done_conversing = next_event!(batsim)
    end
    close_socket(batsim.socket)
end

function next_event!(batsim)
    message = recv_message(batsim.socket)
    batsim.events_to_send = []
    done_conversing = false

    batsim.current_time = message["now"]
    
    for event in message["events"]
        event_type = event["type"]
        if event_type == "SIMULATION_BEGINS"
            manage_event_simulation_begins!(batsim, event["data"])
        elseif event_type == "SIMULATION_ENDS"
            manage_event_simulation_ends!(batsim)
            done_conversing = true
        elseif event_type == "JOB_SUBMITTED"
            manage_event_job_submitted!(batsim, event["data"])
        elseif event_type == "JOB_COMPLETED"
            manage_event_job_complete!(batsim, event["data"])
        elseif event_type == "NOTIFY"
            manage_event_notify!(batsim, event["data"])
        end
    end

    on_no_more_events!(batsim.scheduler)

    # data = Dict("now" => time(batsim), "events" => batsim.events_to_send)
    data = "{\"now\":$(time(batsim)),\"events\":[$(join(batsim.events_to_send, ","))]}"
    send_message(batsim.socket, data)  

    done_conversing
end

function manage_event_notify!(batsim, data)
    # TODO
    # if data["type"] == "no_more_static_job_to_submit"
    #     # println("no more job to submit")
    # end
end

function manage_event_job_complete!(batsim::Batsim, data::Dict{String, Any})
    job_id = data["job_id"]
    job = batsim.jobs[job_id]
    job.finish_time = batsim.current_time
    on_job_completion!(batsim.scheduler, job)
end

function manage_event_job_submitted!(batsim::Batsim, data::Dict{String, Any})
    job_id = data["job_id"]
    job_data = data["job"]
    new_job = Job(job_id, job_data["subtime"], job_data["walltime"], job_data["res"], job_data["profile"])
    # TODO store profile if new
    batsim.jobs[job_id] = new_job

    on_job_submission!(batsim.scheduler, new_job)
end

function manage_event_simulation_begins!(batsim, data)
    # TODO continue
    @assert !batsim.simulation_is_running
    batsim.simulation_is_running = true
    batsim.nb_resources = data["nb_resources"]
    batsim.workloads = data["workloads"]
    batsim.profiles = data["profiles"]

    on_simulation_begins!(batsim.scheduler)
end

function manage_event_simulation_ends!(batsim)
    @assert batsim.simulation_is_running
    batsim.simulation_is_running = false
end

function reject_jobs_by_ids!(batsim, job_ids)
    for job_id in job_ids
        # event = Dict(
        #     "timestamp" => time(batsim),
        #     "type" => "REJECT_JOB",
        #     "data" => Dict("job_id" => job_id)
        # )
        event = "{\"timestamp\":$(time(batsim)),\"type\":\"REJECT_JOB\",\"data\":{\"job_id\":\"$(job_id)\"}}"
        push!(batsim.events_to_send, event)
        # TODO change job state
    end
end

function reject_jobs(batsim, jobs)
    reject_jobs_by_ids!(batsim, jobs .|> x -> x.job_id)
end



function execute_job(batsim::Batsim, job::Job)
    alloc_repr = repr(job.allocation)
    message = message_execute_job(batsim.current_time, job.job_id, alloc_repr)

    batsim.jobs[job.job_id].allocation = job.allocation
    batsim.jobs[job.job_id].job_state = RUNNING
    batsim.jobs[job.job_id].starting_time = batsim.current_time

    push!(batsim.events_to_send, message)
end

function message_execute_job(time::Float64, job_id::String, alloc::String)::String
    "{\"timestamp\":$(time),\"type\":\"EXECUTE_JOB\",\"data\":{\"job_id\":\"$(job_id)\",\"alloc\":\"$(alloc)\"}}"

end

function execute_jobs(batsim::Batsim, jobs::Vector{Job})
    for job in jobs
        execute_job(batsim, job)
    end
end


