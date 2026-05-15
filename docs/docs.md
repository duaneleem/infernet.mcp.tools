# Overall Architecture of mcpo Server

The following MCP tools will be added to this mcpo server:

- [Trello MCP by delorenj](https://github.com/delorenj/mcp-server-trello)
- [Playwright MCP by Microsoft](https://github.com/microsoft/playwright-mcp)
- [Context7 by Upstash](https://github.com/upstash/context7)

## Technical Architecture

Key requirements on how this server works:

- Serves MCP servers through [mcpo](https://github.com/open-webui/mcpo)
- Architecturely built for Docker and Kubernetes.

## Requirements

- No secrets committed to source.
- Serves only for internal namespace/network spaces.
