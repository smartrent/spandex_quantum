defmodule SpandexQuantum.MockNewTracer do
  @moduledoc """
  A class that mocks the calls normally sent to Spandex.Tracer
  """

  def current_trace_id(_) do
    # Return nothing to mock a trace that hasn't started
  end

  def start_trace(name, opts) do
    send(self(), %{func: :start_trace, name: name, opts: opts})
  end

  def finish_trace(opts) do
    send(self(), %{func: :finish_trace, opts: opts})
  end

  def update_span(opts) do
    send(self(), %{func: :update_span, opts: opts})
  end
end
