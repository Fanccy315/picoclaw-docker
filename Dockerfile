# ============================================================
# Stage 1: Build the picoclaw binary
# ============================================================
FROM golang:1.26.0-alpine AS builder

RUN apk add --no-cache git make

RUN git clone --depth 1 --branch v0.2.5 https://github.com/sipeed/picoclaw /src

WORKDIR /src

# Cache dependencies
RUN go mod download

# Build
RUN make build

# ============================================================
# Stage 2: Node.js runtime with Python + MCP support
# ============================================================
FROM node:24-bookworm

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  sudo \
  python3 \
  ffmpeg \
  jq && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Install agent-browser
RUN npm install -g agent-browser && \
  agent-browser install --with-deps

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
  ln -s /root/.local/bin/uv /usr/local/bin/uv && \
  ln -s /root/.local/bin/uvx /usr/local/bin/uvx && \
  uv --version

# Copy binary
COPY --from=builder /src/build/picoclaw /usr/local/bin/picoclaw

ENTRYPOINT ["picoclaw"]
CMD ["gateway"]