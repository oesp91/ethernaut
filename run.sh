#!/usr/bin/env bash
set -Eeuo pipefail

PORT="${ANVIL_PORT:-8545}"
RPC_URL="${ANVIL_RPC_URL:-http://127.0.0.1:${PORT}}"

ANVIL_PID=""
ANVIL_PGID=""
cleanup_ran=0

cleanup() {
  (( cleanup_ran )) && return
  cleanup_ran=1
  echo -e "\n[cleanup] stopping anvil..."
  if [[ -n "${ANVIL_PGID}" ]]; then
    kill -TERM -"${ANVIL_PGID}" 2>/dev/null || true
    sleep 0.7
    kill -KILL -"${ANVIL_PGID}" 2>/dev/null || true
  elif [[ -n "${ANVIL_PID}" ]]; then
    kill -TERM "${ANVIL_PID}" 2>/dev/null || true
    sleep 0.7
    kill -KILL "${ANVIL_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

log() { echo "[$(date +%H:%M:%S)] $*"; }

log "1/5 yarn install"
yarn install

log "2/5 start anvil (logs stream below)"
if command -v setsid >/dev/null 2>&1; then
  setsid bash -lc 'yarn network' &
  ANVIL_PID=$!
  ANVIL_PGID="$(ps -o pgid= -p "${ANVIL_PID}" | tr -d ' ')"
else
  yarn network &
  ANVIL_PID=$!
  ANVIL_PGID="$(ps -o pgid= -p "${ANVIL_PID}" | tr -d ' ' || true)"
fi

# anvil ready check
printf "[wait] waiting for anvil at %s " "$RPC_URL"
for i in {1..60}; do
  if curl -s -m 0.5 -X POST "${RPC_URL}" \
     -H 'Content-Type: application/json' \
     --data '{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}' >/dev/null; then
    echo "OK"
    break
  fi
  printf "."
  sleep 0.5
  if [[ $i -eq 60 ]]; then
    echo " FAILED"; exit 1
  fi
done

log "3/5 yarn compile:contracts"
yarn compile:contracts

log "4/5 yarn deploy:contracts"
export NODE_OPTIONS="--openssl-legacy-provider"
yarn deploy:contracts

log "5/5 yarn start:ethernaut"
yarn start:ethernaut

