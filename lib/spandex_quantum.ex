defmodule SpandexQuantum do
  @moduledoc """
  Documentation for SpandexQuantum.
  """

  def handle_event(
        [:quantum, :job, :start],
        %{system_time: _system_time} = _measurements,
        %{job: job, node: node, scheduler: scheduler} = _metadata,
        _config
      ) do
    if !tracer().current_trace_id([]) do
      tracer().start_trace("#{Atom.to_string(job.name)}", [])

      tracer().update_span(
        type: :background_job_run,
        service: service(),
        start: now(),
        tags: [
          name: Map.get(job, :name, "No name"),
          overlap: to_string(Map.get(job, :overlap, "Unknown")),
          run_strategy: Map.get(job, :run_strategy, "Unknown"),
          schedule: Map.get(job, :schedule, "Unknown"),
          state: Map.get(job, :state, "Unknown"),
          task: Map.get(job, :task, "Unknown"),
          timezone: Map.get(job, :timezone, "Unknown"),
          job_status: "Started",
          node: node,
          scheduler: scheduler
        ]
      )
    end
  end

  def handle_event(
        [:quantum, :job, :stop],
        %{duration: _duration} = _measurements,
        %{job: job, node: node, scheduler: scheduler} = _metadata,
        _config
      ) do
    if tracer().current_trace_id([]) do
      tracer().finish_trace(
        service: service(),
        completion_time: now(),
        tags: [
          name: Map.get(job, :name, "No name"),
          overlap: to_string(Map.get(job, :overlap, "Unknown")),
          run_strategy: Map.get(job, :run_strategy, "Unknown"),
          schedule: Map.get(job, :schedule, "Unknown"),
          state: Map.get(job, :state, "Unknown"),
          task: Map.get(job, :task, "Unknown"),
          job_status: "Passed",
          node: node,
          scheduler: scheduler
        ]
      )
    end
  end

  def handle_event(
        [:quantum, :job, :exception],
        %{duration: _duration} = _measurements,
        %{
          job: job,
          node: node,
          scheduler: scheduler,
          reason: reason,
          stacktrace: stacktrace
        } = _metadata,
        _config
      ) do
    if tracer().current_trace_id([]) do
      if reason do
        tracer().span_error(%RuntimeError{message: inspect(reason)}, stacktrace)
      else
        tracer().span_error(%RuntimeError{message: "background job error"}, stacktrace)
      end

      # spans are updated with the opts passed into `finish_trace`
      tracer().finish_trace(
        error: [error?: true],
        type: :background_job_run,
        completion_time: now(),
        service: service(),
        tags: [
          name: Map.get(job, :name, "No name"),
          overlap: to_string(Map.get(job, :overlap, "Unknown")),
          run_strategy: Map.get(job, :run_strategy, "Unknown"),
          schedule: Map.get(job, :schedule, "Unknown"),
          state: Map.get(job, :state, "Unknown"),
          task: Map.get(job, :task, "Unknown"),
          timezone: Map.get(job, :timezone, "Unknown"),
          job_status: "Failed",
          node: node,
          scheduler: scheduler
        ]
      )
    end
  end

  def handle_event(
        [:quantum, :job, :add],
        _measurements,
        %{job: job, scheduler: _scheduler} = _metadata,
        _config
      ) do
    tracer().start_trace("#{Atom.to_string(job.name)}", [])

    tracer().finish_trace(
      type: :background_job_add,
      service: service(),
      tags: [
        job_status: "Added"
      ]
    )
  end

  def handle_event(
        [:quantum, :job, :delete],
        _measurements,
        %{job: job, scheduler: _scheduler} = _metadata,
        _config
      ) do
    tracer().start_trace("#{Atom.to_string(job.name)}", [])

    tracer().finish_trace(
      type: :background_job_delete,
      service: service(),
      tags: [
        job_status: "Deleted"
      ]
    )
  end

  def handle_event(
        [:quantum, :job, :update],
        _measurements,
        %{job: job, scheduler: _scheduler} = _metadata,
        _config
      ) do
    tracer().start_trace("#{Atom.to_string(job.name)}", [])

    tracer().finish_trace(
      type: :background_job_update,
      service: service(),
      tags: [
        job_status: "Updated"
      ]
    )
  end

  defp tracer do
    Application.fetch_env!(:spandex_quantum, :tracer)
  end

  defp service do
    Application.get_env(:spandex_quantum, :service, :quantum)
  end

  defp now do
    clock_adapter().system_time()
  end

  defp clock_adapter do
    Application.get_env(:spandex_quantum, :clock_adapter, System)
  end
end
