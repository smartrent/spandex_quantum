defmodule SpandexQuantum.MockExistingTracer do
  @moduledoc """
  A class that mocks the calls normally sent to Spandex.Tracer
  """

  def current_trace_id(_) do
    # Return a fake id to mock a trace that already exists
    123
  end

  def finish_trace(opts) do
    send(self(), %{func: :finish_trace, opts: opts})
  end

  def span_error(error, stacktrace) do
    send(self(), %{func: :finish_trace, error: error, stacktrace: stacktrace})
  end
end
