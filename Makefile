.PHONY: deps-get test

include funbox.mk

# FunBox Pipeline

prep:
	make compile

build:
	true

check:
	make check-syntax
	make test
	make dialyzer
	make credo
	make cover

clean:
	true

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

hex-publish:
	env HEX_API_URL="https://hex.funbox.ru/api/repos/funbox" \
		HEX_API_KEY="$$(ghettoauth show-credentials -c fb-corptools-prod -r hex_user -b)" \
		mix hex.publish package
