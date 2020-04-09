.PHONY: test

test: export MIX_ENV=test
test:
	mix clean && mix compile --warnings-as-errors
	mix format --check-formatted --dry-run
	mix test
	mix dialyzer
	mix credo --strict
