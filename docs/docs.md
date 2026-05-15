# infernet.mcp.tools — planning brief (mcpo host)

Use this document as the **source of truth for scope and constraints** when designing Docker/Kubernetes manifests, mcpo configuration, and MCP server wiring.

## Purpose

Run multiple MCP tool servers behind **[mcpo](https://github.com/open-webui/mcpo)** so **Open WebUI** (or any MCP-capable agent runtime) can call them through a single, managed gateway. Optimize for **internal** deployments only.

## Primary consumer

- **Open WebUI** is the intended client; any MCP-capable system can consume the same endpoints if allowed on the network.

## In scope

- mcpo as the process that exposes MCP servers to clients.
- Container images and K8s-style deployment (namespaces, services, secrets as external references—not committed values).
- Configuration for the MCP servers listed below (env vars, command args, health/readiness where applicable).

## Out of scope (unless explicitly expanded later)

- Public internet exposure or multi-tenant auth at the edge.
- Committing API keys, tokens, kubeconfig, or `.env` files with real values.

## Planned MCP servers

| Priority | Server        | Upstream                                                                 | Role (for planning)                          |
| -------- | ------------- | ------------------------------------------------------------------------ | -------------------------------------------- |
| 1        | Trello MCP    | [delorenj/mcp-server-trello](https://github.com/delorenj/mcp-server-trello) | Board/card operations via Trello API         |
| 2        | Playwright MCP | [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp)   | Browser automation (resource-heavy; sandbox) |
| 3        | Context7      | [upstash/context7](https://github.com/upstash/context7)                  | Library/docs context for coding agents       |

When planning each integration, capture **required env vars**, **default ports/paths**, **filesystem needs** (e.g. Playwright browsers), and **failure modes** (timeouts, headless deps).

## Architecture constraints

- **Gateway:** All MCP traffic is expected to flow through **mcpo**, not ad-hoc sidecars per tool unless mcpo docs require it.
- **Runtime:** Target **Docker** for local/dev parity and **Kubernetes** for internal cluster deployment.
- **Network:** Design for **internal namespaces / private networks** only; assume no anonymous public access.

## Production assets (repo layout)

Production / final container definitions live under **`techops/production/`** (not at the repository root):

- **`techops/production/docker-compose.production.yaml`** — production Compose stack
- **`techops/production/production.Dockerfile`** — production image build

## Security and compliance

- **No secrets in git:** Use K8s Secrets, sealed secrets, or external secret managers; reference keys by name in docs and manifests only.
- **Least privilege:** Grant each MCP server only the credentials it needs (e.g. Trello token ≠ cluster admin).

## Implementation checklist (for agents)

Use this as a task breakdown; order may shift after spiking mcpo + one MCP.

1. [ ] Pin mcpo version and document the invocation model (CLI args, config file format, port).
2. [ ] Define or extend **`techops/production/docker-compose.production.yaml`** (and **`techops/production/production.Dockerfile`** as needed) so mcpo + at least one MCP runs end-to-end for smoke tests.
3. [ ] Add per-MCP blocks: image or install method, env schema, resource limits (especially Playwright).
4. [ ] Add Kubernetes manifests (or Helm chart) with internal `Service`, probes, and secret references—no literal secrets.
5. [ ] Document how Open WebUI points at this host (URL, auth expectations if any).
6. [ ] Add operational notes: logging, restart policy, upgrade path for upstream MCP repos.

## Open decisions (fill in as the project evolves)

- Exact mcpo version and config layout (single file vs. layered overrides).
- Whether Playwright runs in the same pod as mcpo or an isolated workload with shared socket/volume—depends on mcpo and cluster policy.
- Authn/z between Open WebUI and mcpo (if any beyond network policy).

## Success criteria

- A new engineer (or agent) can stand up the stack from repo docs without guessing secret locations.
- Each planned MCP is **listed with upstream link, purpose, and config surface** before production wiring.
- Deployments assume **internal-only** networking unless this document is explicitly updated.

## References

- [mcpo](https://github.com/open-webui/mcpo)
- [Trello MCP (delorenj)](https://github.com/delorenj/mcp-server-trello)
- [Playwright MCP (Microsoft)](https://github.com/microsoft/playwright-mcp)
- [Context7 (Upstash)](https://github.com/upstash/context7)
