.PHONY: deps-get test

prep:
	make compile

ci: prep
	make check-syntax
	make test
	make dialyzer
	make credo
	make cover

# Commands

deps-get:
	mix deps.get

deps-update:
	mix deps.update --all

compile: deps-get
	mix compile

test:
	mix test --trace

check-syntax:
	mix clean && mix compile --warnings-as-errors
	mix format --check-formatted --dry-run

credo:
	mix credo --strict

dialyzer:
	mix dialyzer

cover:
	mix cover
	mix cover.lint
