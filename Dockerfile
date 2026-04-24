FROM node:24-bookworm

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates \
  curl wget \
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

# Install picoclaw
RUN wget -O /tmp/picoclaw.tar.gz \
  "https://github.com/sipeed/picoclaw/releases/download/v0.2.7/picoclaw_Linux_x86_64.tar.gz" && \
  mkdir -p /tmp/picoclaw_extract && \
  tar -xzf /tmp/picoclaw.tar.gz -C /tmp/picoclaw_extract && \
  mv /tmp/picoclaw_extract/picoclaw /usr/local/bin/ && \
  mv /tmp/picoclaw_extract/picoclaw-launcher /usr/local/bin/ && \
  rm -rf /tmp/picoclaw.tar.gz /tmp/picoclaw_extract

ENTRYPOINT ["picoclaw"]
CMD ["gateway"]