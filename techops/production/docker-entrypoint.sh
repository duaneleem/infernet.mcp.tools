#!/bin/sh
set -e
PORT="${MCPO_PORT:-8000}"
HOST="${MCPO_HOST:-0.0.0.0}"

if [ -n "$MCPO_API_KEY" ]; then
  if [ "$MCPO_STRICT_AUTH" = "1" ] || [ "$MCPO_STRICT_AUTH" = "true" ]; then
    exec mcpo --host "$HOST" --port "$PORT" --config /app/mcp-servers.json --api-key "$MCPO_API_KEY" --strict-auth "$@"
  else
    exec mcpo --host "$HOST" --port "$PORT" --config /app/mcp-servers.json --api-key "$MCPO_API_KEY" "$@"
  fi
else
  if [ "$MCPO_STRICT_AUTH" = "1" ] || [ "$MCPO_STRICT_AUTH" = "true" ]; then
    exec mcpo --host "$HOST" --port "$PORT" --config /app/mcp-servers.json --strict-auth "$@"
  else
    exec mcpo --host "$HOST" --port "$PORT" --config /app/mcp-servers.json "$@"
  fi
fi
