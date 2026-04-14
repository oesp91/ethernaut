# Ethernaut Local Fork

This repository is a fork of OpenZeppelin's Ethernaut codebase, modified to make local development and local gameplay setup reproducible.

The main changes in this fork are focused on:

- one-command local startup
- Docker Compose based local infrastructure
- local deployment/runtime fixes for recent toolchains
- stable local syntax highlighting and MetaMask flow

The original upstream project lives at:

- https://github.com/OpenZeppelin/ethernaut
- https://ethernaut.openzeppelin.com

## Local Setup

This fork is intended to be run in one of these two ways.

### local startup

If you want to boot the local Anvil node, compile and deploy the contracts, and then start the frontend in one command:

```bash
yarn local:start
```

This script runs Ethernaut only against the local network, creates `client/src/gamedata/deploy.local.json` if needed, writes Anvil logs to `.local/anvil.log`, and keeps Anvil alive for as long as the frontend process is running.

Use the Node version from `.nvmrc` (`v16.20.1`) for the most predictable local behavior.

After startup, import one of the Anvil private keys into MetaMask and connect MetaMask to `http://127.0.0.1:8545` with chain ID `31337`.

### Docker Compose startup

If you want a reproducible local environment with Anvil and the frontend separated into containers:

```bash
docker compose up --build
```

or

```bash
yarn docker:start
```

This exposes:

- `http://localhost:3000` for the frontend
- `http://127.0.0.1:8545` for the local Anvil RPC

After the containers are up, import one of the Anvil private keys into MetaMask and connect MetaMask to `http://127.0.0.1:8545` with chain ID `31337`.

### Running tests

```bash
yarn test:contracts
```
