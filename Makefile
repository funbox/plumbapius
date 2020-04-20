.PHONY: test

test: export MIX_ENV=test
test:
	mix clean && mix compile --warnings-as-errors
	mix format --check-formatted --dry-run
	mix test
	mix dialyzer
	mix credo --strict
	mix cover
	mix cover.lint

hex-publish:
	env HEX_API_URL="https://hex.funbox.ru/api/repos/funbox" \
		HEX_API_KEY="$$(ghettoauth show-credentials -c fb-corptools-prod -r hex_user -b)" \
		mix hex.publish package
