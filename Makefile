install:
	mix deps.get

pre-push:
	make compile && make lint && make test

compile:
	rm -rf _build/dev/lib/quantum && mix compile --warnings-as-errors

lint:
	mix format && mix dialyzer --format dialyxir && mix credo --strict

test:
	mix test
