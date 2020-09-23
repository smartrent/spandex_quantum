defmodule SpandexQuantumTest do
  use ExUnit.Case
  doctest SpandexQuantum

  test "start call" do
    Application.put_env(:spandex_quantum, :tracer, SpandexQuantum.MockNewTracer)

    SpandexQuantum.handle_event(
      [:quantum, :job, :start],
      %{system_time: ~D[2000-01-01]},
      %{job: %{name: :ma_job}, node: :fake_testing_node, scheduler: :fake_scheduler},
      %{}
    )

    assert_receive %{func: :start_trace, name: "background_job_run", opts: []}

    assert_receive %{
      func: :update_span,
      opts: [
        resource: "ma_job",
        type: :background_job,
        service: :quantum,
        start: _now,
        tags: [
          name: :ma_job,
          overlap: "Unknown",
          run_strategy: "Unknown",
          schedule: "Unknown",
          state: "Unknown",
          task: "Unknown",
          timezone: "Unknown",
          job_status: "Started",
          node: :fake_testing_node,
          scheduler: :fake_scheduler
        ]
      ]
    }

    assert name = 1
  end

  test "stop call" do
    Application.put_env(:spandex_quantum, :tracer, SpandexQuantum.MockExistingTracer)

    SpandexQuantum.handle_event(
      [:quantum, :job, :stop],
      %{duration: 5},
      %{job: %{name: :ma_job}, node: :fake_testing_node, scheduler: :fake_scheduler},
      %{}
    )

    assert_receive %{
      func: :finish_trace,
      opts: [
        service: :quantum,
        completion_time: _now,
        tags: [
          name: :ma_job,
          overlap: "Unknown",
          run_strategy: "Unknown",
          schedule: "Unknown",
          state: "Unknown",
          task: "Unknown",
          job_status: "Passed",
          node: :fake_testing_node,
          scheduler: :fake_scheduler
        ]
      ]
    }

    assert name = 1
  end

  test "exception call" do
    Application.put_env(:spandex_quantum, :tracer, SpandexQuantum.MockExistingTracer)

    stacktrace = [
      {Test.FailedJobs, :exitFunction, 0, [file: 'config/scheduled_jobs.exs', line: 12]},
      {Quantum.Executor, :"-run/5-fun-4-", 6, [file: 'lib/quantum/executor.ex', line: 108]},
      {Task.Supervised, :invoke_mfa, 2, [file: 'lib/task/supervised.ex', line: 90]},
      {Task.Supervised, :reply, 5, [file: 'lib/task/supervised.ex', line: 35]},
      {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 249]}
    ]

    SpandexQuantum.handle_event(
      [:quantum, :job, :exception],
      %{duration: 5},
      %{
        job: %{name: :ma_job},
        node: :fake_testing_node,
        scheduler: :fake_scheduler,
        reason: "Fake Error",
        stacktrace: stacktrace
      },
      %{}
    )

    assert_receive %{
      error: %RuntimeError{message: "\"Fake Error\""},
      func: :finish_trace,
      stacktrace: [
        {Test.FailedJobs, :exitFunction, 0, [file: 'config/scheduled_jobs.exs', line: 12]},
        {Quantum.Executor, :"-run/5-fun-4-", 6, [file: 'lib/quantum/executor.ex', line: 108]},
        {Task.Supervised, :invoke_mfa, 2, [file: 'lib/task/supervised.ex', line: 90]},
        {Task.Supervised, :reply, 5, [file: 'lib/task/supervised.ex', line: 35]},
        {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 249]}
      ]
    }

    assert_receive %{
      func: :finish_trace,
      opts: [
        error: [error?: true],
        type: :background_job,
        completion_time: _now,
        service: :quantum,
        tags: [
          name: :ma_job,
          overlap: "Unknown",
          run_strategy: "Unknown",
          schedule: "Unknown",
          state: "Unknown",
          task: "Unknown",
          timezone: "Unknown",
          job_status: "Failed",
          node: :fake_testing_node,
          scheduler: :fake_scheduler
        ]
      ]
    }

    assert name = 1
  end

  test "added job" do
    Application.put_env(:spandex_quantum, :tracer, SpandexQuantum.MockNewTracer)

    SpandexQuantum.handle_event(
      [:quantum, :job, :add],
      %{},
      %{job: %{name: :ma_job}, node: :fake_testing_node, scheduler: :fake_scheduler},
      %{}
    )

    assert_receive %{func: :start_trace, name: "background_job_add", opts: []}

    assert_receive %{
      func: :finish_trace,
      opts: [
        resource: "ma_job",
        type: :background_job,
        service: :quantum,
        tags: [job_status: "Added"]
      ]
    }

    assert name = 1
  end

  test "deleted job" do
    Application.put_env(:spandex_quantum, :tracer, SpandexQuantum.MockNewTracer)

    SpandexQuantum.handle_event(
      [:quantum, :job, :delete],
      %{},
      %{job: %{name: :ma_job}, node: :fake_testing_node, scheduler: :fake_scheduler},
      %{}
    )

    assert_receive %{func: :start_trace, name: "background_job_delete", opts: []}

    assert_receive %{
      func: :finish_trace,
      opts: [
        resource: "ma_job",
        type: :background_job,
        service: :quantum,
        tags: [job_status: "Deleted"]
      ]
    }

    assert name = 1
  end

  test "updated job" do
    Application.put_env(:spandex_quantum, :tracer, SpandexQuantum.MockNewTracer)

    SpandexQuantum.handle_event(
      [:quantum, :job, :update],
      %{},
      %{job: %{name: :ma_job}, node: :fake_testing_node, scheduler: :fake_scheduler},
      %{}
    )

    assert_receive %{func: :start_trace, name: "background_job_update", opts: []}

    assert_receive %{
      func: :finish_trace,
      opts: [
        resource: "ma_job",
        type: :background_job,
        service: :quantum,
        tags: [job_status: "Updated"]
      ]
    }

    assert name = 1
  end
end
