# Production stack (Docker)

Everything runs **inside the mcpo container** built from this directory: no host Node, `npx`, or Python required for production use.

## Files

| File | Role |
|------|------|
| `mcp-servers.json` | Claude-style `mcpServers` map passed to `mcpo --config` (Trello, Context7, Playwright). |
| `production.Dockerfile` | `FROM ghcr.io/open-webui/mcpo` at a **pinned digest** (GHCR has no `v0.0.x` tags; bump digest when upgrading), pre-installs Chromium for `@playwright/mcp@0.0.75`, copies config. |
| `docker-entrypoint.sh` | Starts `mcpo` with optional `MCPO_API_KEY` / `MCPO_STRICT_AUTH`. |
| `docker-compose.production.yaml` | Build, port publish, `env_file` `.env` in this directory, `shm_size` for Playwright. |

## Environment

[mcpo](https://github.com/open-webui/mcpo) merges **process environment** with each server’s optional `env` block when spawning MCP children (`os.environ` merged with config). This image does **not** put secrets in JSON; set variables in **`techops/production/.env`** (copy from [`template.env`](template.env)).

## Run (from repository root)

```bash
cp techops/production/template.env techops/production/.env
# edit techops/production/.env …
docker compose -f techops/production/docker-compose.production.yaml --env-file techops/production/.env up --build
```

Fill **`TRELLO_*`**, **`CONTEXT7_API_KEY`**, and optional **`MCPO_API_KEY`** in **`techops/production/.env`** before expecting those MCPs to initialize; mcpo still serves HTTP and `/docs` while individual stdio MCPs may fail until credentials are set.

Open `http://localhost:${MCPO_PORT:-8000}/docs` (per-tool docs under paths like `/trello/docs` per mcpo).
