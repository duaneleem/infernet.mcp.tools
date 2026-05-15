# infernet.mcp.tools

MCP tool servers run behind **[mcpo](https://github.com/open-webui/mcpo)** so **[Open WebUI](https://github.com/open-webui/open-webui)** (or any MCP client on your network) can use them through one gateway.

## How this is deployed (high level)

1. **Define MCP servers** — Decide which MCP processes mcpo will start (see [docs/docs.md](docs/docs.md)) and what each one needs: command, image or install path, environment variables, and resource hints (browser-heavy tools need more CPU/RAM and often a writable cache).

2. **Configure mcpo** — Point mcpo at that server list (per [mcpo](https://github.com/open-webui/mcpo) docs): host/port to listen on, and how each child MCP is launched. Keep **secrets out of git**; inject them at runtime (Docker/Kubernetes secrets, secret manager, or local env files that are not committed).

3. **Run the gateway**  
   - **Local or small env:** Run mcpo (and dependencies) with Docker Compose or equivalent so behavior matches prod enough to debug.  
   - **Kubernetes:** Deploy mcpo as a workload in an **internal** namespace, expose it with a `ClusterIP` (or private ingress) service, mount secrets as env or files, and set requests/limits—especially if Playwright or similar runs alongside.

4. **Connect Open WebUI** — In Open WebUI, add the MCP integration using the **base URL** of your mcpo instance on the network the UI can reach (same cluster/VPC/VPN as appropriate). Use TLS and network policy if your policy requires it.

5. **Verify** — From a client that can reach mcpo, confirm tools list and one representative call per MCP before rolling out broadly.

For scope, security assumptions, and a detailed planning checklist, see **[docs/docs.md](docs/docs.md)**.
