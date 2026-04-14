FROM ghcr.io/foundry-rs/foundry:stable AS foundry

FROM node:16-bookworm

RUN apt-get update \
  && apt-get install -y --no-install-recommends bash curl ca-certificates git \
  && rm -rf /var/lib/apt/lists/*

COPY --from=foundry /usr/local/bin/anvil /usr/local/bin/anvil
COPY --from=foundry /usr/local/bin/forge /usr/local/bin/forge
COPY --from=foundry /usr/local/bin/cast /usr/local/bin/cast

WORKDIR /app

CMD ["bash"]
