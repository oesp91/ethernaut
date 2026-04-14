#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/.local"
ANVIL_LOG="$LOG_DIR/anvil.log"
DEPLOY_DATA="$ROOT_DIR/client/src/gamedata/deploy.local.json"
RPC_HOST="${ETHERNAUT_RPC_HOST:-http://127.0.0.1}"
RPC_URL="${RPC_HOST}:8545"
START_ANVIL="${START_ANVIL:-1}"

mkdir -p "$LOG_DIR"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

cleanup() {
  if [[ -n "${ANVIL_PID:-}" ]] && kill -0 "$ANVIL_PID" >/dev/null 2>&1; then
    kill "$ANVIL_PID" >/dev/null 2>&1 || true
  fi
}

wait_for_rpc() {
  local attempts=30

  for ((i=1; i<=attempts; i++)); do
    if curl -fsS \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
      "$RPC_URL" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "Anvil RPC did not become ready on $RPC_URL" >&2
  exit 1
}

require_cmd yarn
require_cmd node
require_cmd forge
require_cmd curl

if [[ "$START_ANVIL" == "1" ]]; then
  require_cmd anvil
fi

trap cleanup EXIT INT TERM

cd "$ROOT_DIR"

if [[ ! -f node_modules/prompt/package.json ]]; then
  echo "Installing dependencies with yarn..."
  yarn install
fi

if [[ ! -f "$DEPLOY_DATA" ]]; then
  echo "{}" > "$DEPLOY_DATA"
fi

if [[ "$START_ANVIL" == "1" ]]; then
  echo "Starting Anvil on $RPC_URL..."
  anvil --host 0.0.0.0 --block-time 1 --auto-impersonate >"$ANVIL_LOG" 2>&1 &
  ANVIL_PID=$!
else
  echo "Using external Anvil on $RPC_URL..."
fi

wait_for_rpc

echo "Compiling contracts..."
yarn compile:contracts

echo "Deploying contracts to local Anvil..."
printf 'y\n' | yarn deploy:contracts

echo "Starting Ethernaut frontend on http://localhost:3000 ..."
HOST="${HOST:-0.0.0.0}" yarn start:ethernaut
