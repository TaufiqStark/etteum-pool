FROM oven/bun:1.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    postgresql-client \
    curl \
    procps \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libxt6 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libdrm2 \
    libgbm1 \
    libasound2 \
    libxss1 \
    libxtst6 \
    fonts-liberation \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files first for better caching
COPY package.json bun.lock* ./
COPY dashboard/package.json dashboard/bun.lock* ./dashboard/

# Install root dependencies
RUN bun install

# Install additional runtime deps
RUN bun add hono @hono/node-server drizzle-orm drizzle-kit postgres dotenv ws

# Install dashboard dependencies
RUN cd dashboard && bun install

# Copy the rest of the application
COPY . .

# Setup Python venv and install auth bot dependencies
RUN python3 -m venv scripts/auth/.venv && \
    scripts/auth/.venv/bin/pip install --no-cache-dir -r scripts/auth/requirements.txt && \
    scripts/auth/.venv/bin/python -m playwright install chromium && \
    scripts/auth/.venv/bin/python -m camoufox fetch

RUN cd dashboard && VITE_BACKEND_PORT=1630 bun run build

# Make entrypoint executable
RUN chmod +x entrypoint.sh

EXPOSE 1630 1631

# Start production
CMD ["./entrypoint.sh"]