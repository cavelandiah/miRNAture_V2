#!/bin/sh
set -eu

# Backward-compatible singular alias for the unit-only runner.
exec "$(dirname "$0")/unit-tests.sh" "$@"
