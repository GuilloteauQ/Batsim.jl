# This is a template of scheduler 

mutable struct TemplateScheduler
  batsim
end

function on_after_batsim_init!(sche)
  throw("unimplemented")
end

function on_simulation_begins!(sched)
  throw("unimplemented")
end

function on_simulation_ends!(sched)
  throw("unimplemented")
end

function on_dead_lock!(sched)
  throw("unimplemented")
end

function on_job_submission!(sched, job)
  throw("unimplemented")
end

function on_job_completion!(sched, job)
  throw("unimplemented")
end

function on_job_message!(sched, timestamp, job, message)
  throw("unimplemented")
end

function on_jobs_killed!(sched, jobs)
  throw("unimplemented")
end

function on_add_resources!(sched, to_add)
  throw("unimplemented")
end

function on_remove_resources!(sched, to_remove)
  throw("unimplemented")
end

function on_requested_call!(sched)
  throw("unimplemented")
end

function on_no_more_jobs_in_workloads!(sched)
  println("No more static jobs in the workloads")
end

function on_no_more_external_events!(sched)
  println("No more external events")
end

function on_notify_event_machine_unavailable!(sched, machines)
  throw("unimplemented")
end

function on_notify_event_machine_available!(sched, machines)
  throw("unimplemented")
end

function on_notify_generic_event!(sched, event_data)
  throw("unimplemented")
end

function on_before_events!(sched)
  # TODO
end

function on_no_more_events!(sched)
  # TODO
end