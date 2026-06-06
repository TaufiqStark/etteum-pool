# Running with Podman/Docker Compose

## Prerequisites

- Podman or Docker with Compose support
- Git

## Quick Start

1. Clone repository:
```bash
git clone https://github.com/priyo000/etteum-pool.git poolprox2
cd poolprox2
```

2. Setup environment:
```bash
cp .env.docker .env
```

3. Generate encryption key (optional but recommended):
```bash
# Linux/macOS
sed -i "s/ENCRYPTION_KEY=.*/ENCRYPTION_KEY=$(openssl rand -hex 16)/" .env

# Windows PowerShell
$key = -join ((48..57) + (97..102) | Get-Random -Count 32 | ForEach-Object {[char]$_})
(Get-Content .env) -replace 'ENCRYPTION_KEY=.*', "ENCRYPTION_KEY=$key" | Set-Content .env
```

4. Start services:
```bash
# With Podman
podman-compose up -d

# With Docker
docker compose up -d
```

5. Check logs:
```bash
podman-compose logs -f poolprox
```

6. Access:
- Dashboard: http://localhost:1631
- API: http://localhost:1630

## Configuration

Edit `.env` file to customize:

- `API_KEY` - Bearer token for API access
- `ENCRYPTION_KEY` - 32 hex chars for encrypting stored credentials
- `BROWSER_ENGINE` - `camoufox` (default) or `chromium`
- `HEADLESS` - `true` (default) or `false`
- `PROXY_URL` - Optional outbound proxy for auth bot

## Management Commands

```bash
# Start
podman-compose up -d

# Stop
podman-compose down

# Restart
podman-compose restart

# View logs
podman-compose logs -f

# Rebuild after code changes
podman-compose up -d --build

# Clean everything (including database)
podman-compose down -v
```

## Troubleshooting

**Port already in use:**
```bash
# Change ports in .env
PORT=1640
DASHBOARD_PORT=1641

# Restart
podman-compose down
podman-compose up -d
```

**Database connection failed:**
```bash
# Check postgres health
podman-compose ps

# View postgres logs
podman-compose logs postgres
```

**Auth bot fails:**
```bash
# Check if Python dependencies installed correctly
podman-compose exec poolprox ls -la scripts/auth/.venv

# Rebuild container
podman-compose up -d --build
```

**Container keeps restarting:**
```bash
# View full logs
podman-compose logs poolprox

# Common issues:
# - Missing ENCRYPTION_KEY in .env
# - Database not ready (wait 30s after first start)
# - Port conflict (change PORT in .env)
```

## Development Mode

For development with hot reload:

```bash
# Start only database
podman-compose up -d postgres

# Run app locally
bun run dev
```

## Notes

- First build takes 5-10 minutes (installs Playwright + Camoufox)
- Database persists in `postgres_data` volume
- Dashboard is pre-built and served as static files
- Migrations run automatically on startup
