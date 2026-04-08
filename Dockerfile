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
FROM node:24-alpine3.23

RUN apk add --no-cache \
  ca-certificates \
  curl \
  git \
  python3 \
  py3-pip \
  chromium \
  jq

# Install Playwright browsers for agent-browser
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright-browsers
RUN npm install -g agent-browser && \
    npx playwright install chromium && \
    chmod -R o+rx $PLAYWRIGHT_BROWSERS_PATH

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
  ln -s /root/.local/bin/uv /usr/local/bin/uv && \
  ln -s /root/.local/bin/uvx /usr/local/bin/uvx && \
  uv --version

# Copy binary
COPY --from=builder /src/build/picoclaw /usr/local/bin/picoclaw

# Run onboard to create initial directories and config
RUN /usr/local/bin/picoclaw onboard

ENTRYPOINT ["picoclaw"]
CMD ["gateway"]