import Config

config :plug, validate_header_keys_during_test: true
config :plumbapius, coverage_tracker: FakeCoverageTracker
