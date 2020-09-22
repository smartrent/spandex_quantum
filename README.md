# SpandexQuantum
Tracing integration between quantum and spandex

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `spandex_quantum` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spandex_quantum, "~> 0.1.0"}
  ]
end
```


## Configuration

Configure spandex_quantum to use your App's `Spandex.Tracer` module in config.exs:

```elixir
config :spandex_quantum,
  tracer: MyApp.Tracer
```

Add the Telemetry plug to your Quantum Scheduler:

```elixir
defmodule MyApp.Scheduler do
  use Quantum,
    otp_app: :my_app
end
```

Attached the telemetry handler to your `application.ex`:

```elixir
:telemetry.attach_many(
  "spandex-quantum-tracer",
  [
    [:quantum, :job, :add],
    [:quantum, :job, :delete],
    [:quantum, :job, :update],
    [:quantum, :job, :start],
    [:quantum, :job, :stop],
    [:quantum, :job, :exception]
  ],
  &SpandexQuantum.handle_event/4,
  nil
)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/spandex_quantum](https://hexdocs.pm/spandex_quantum).

## Contributing

1. clone and branch off
1. run `make install`
1. run `make pre-push` to verify master is clean
1. write your tests and make changes to source
1. run `make pre-push` again to verify your changes pass
1. add yourself to the contibuters list in your branch
1. Make a PR and request @mrmarcsmith who will review within 0 to INT_MAX days. (probably)
