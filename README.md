# Ethernaut Local Fork

This repository is a fork of OpenZeppelin's Ethernaut codebase, modified to make local development and local gameplay setup reproducible.

The original upstream project lives at:

- https://github.com/OpenZeppelin/ethernaut
- https://ethernaut.openzeppelin.com

### Docker Setup

Run:

```bash
docker compose up --build
```

This exposes:

- `http://localhost:3000` for the frontend
- `http://127.0.0.1:8545` for the local Anvil RPC

After the containers are up, import one of the Anvil private keys into MetaMask and connect MetaMask to `http://127.0.0.1:8545` with chain ID `31337`.
