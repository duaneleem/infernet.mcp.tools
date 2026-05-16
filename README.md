# infernet.mcp.tools

MCP tool servers run behind **[mcpo](https://github.com/open-webui/mcpo)** so **[Open WebUI](https://github.com/open-webui/open-webui)** (or any MCP client on your network) can use them through one gateway.

## How this is deployed (high level)

1. **Define MCP servers** — Decide which MCP processes mcpo will start (see [docs/docs.md](docs/docs.md)) and what each one needs: command, image or install path, environment variables, and resource hints (browser-heavy tools need more CPU/RAM and often a writable cache).

2. **Configure mcpo** — Point mcpo at that server list (per [mcpo](https://github.com/open-webui/mcpo) docs): host/port to listen on, and how each child MCP is launched. Keep **secrets out of git**; inject them at runtime (Docker/Kubernetes secrets, secret manager, or local env files that are not committed).

3. **Run the gateway**  
   - **Docker (recommended):** Use [techops/production/docker-compose.production.yaml](techops/production/docker-compose.production.yaml) so mcpo and all MCP children run **only inside the container**—no host `mcpo` or `npx` required.  
   - **Kubernetes:** Deploy the same image as a workload in an **internal** namespace, expose it with a `ClusterIP` (or private ingress) service, mount secrets as env or files, and set requests/limits—especially if Playwright or similar runs alongside.

4. **Connect Open WebUI** — In Open WebUI, add the MCP integration using the **base URL** of your mcpo instance on the network the UI can reach (same cluster/VPC/VPN as appropriate). Use TLS and network policy if your policy requires it.

5. **Verify** — From a client that can reach mcpo, confirm tools list and one representative call per MCP before rolling out broadly.

## Production: Docker only

Run the gateway **only in a container** (no host `mcpo` / `npx` required). From the repository root, after copying [`techops/production/template.env`](techops/production/template.env) to `techops/production/.env` and filling secrets:

```bash
docker compose -f techops/production/docker-compose.production.yaml --env-file techops/production/.env up --build
```

- **Docs UI:** `http://localhost:${MCPO_PUBLISH_PORT:-8000}/docs` (set `MCPO_PUBLISH_PORT` in `techops/production/.env` to change the **host** port; mcpo always listens on port `8000` inside the container). Per-tool OpenAPI lives under paths such as `/trello/docs`, `/context7/docs`, `/playwright/docs` (see [mcpo](https://github.com/open-webui/mcpo)).
- **Compose / Dockerfile / `mcp-servers.json`:** [techops/production/README.md](techops/production/README.md).

For scope, security assumptions, and a detailed planning checklist, see **[docs/docs.md](docs/docs.md)**.
