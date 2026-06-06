#!/bin/sh
set -e

cleanup() {
  echo "Shutting down gracefully..."
  if [ -n "$child" ]; then
    kill "$child" 2>/dev/null || true
    wait "$child" 2>/dev/null || true
  fi
  exit 0
}

trap cleanup INT TERM

echo "Waiting for database..."
until pg_isready -h postgres -U postgres; do
  sleep 1
done

echo "Starting server (migrations run automatically)..."
bun src/index.ts &
child=$!
wait "$child"