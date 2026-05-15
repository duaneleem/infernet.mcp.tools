# Pinned gateway image (GHCR does not publish semver tags; digest pins a reproducible build).
FROM ghcr.io/open-webui/mcpo@sha256:1e82c9555c19e50b80745705f32b47a2647589f35279527b5118ecd3a71bd467

USER root

# Match @playwright/mcp browser install path used at build time.
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    PLAYWRIGHT_MCP_BROWSER=chromium \
    PLAYWRIGHT_MCP_HEADLESS=true

WORKDIR /opt/pw-bake
RUN npm init -y \
  && npm install @playwright/mcp@0.0.75 \
  && mkdir -p /ms-playwright \
  && ./node_modules/.bin/playwright install-deps chromium \
  && ./node_modules/.bin/playwright install chromium \
  && rm -rf /opt/pw-bake/node_modules /opt/pw-bake/package-lock.json /root/.npm

WORKDIR /app
COPY mcp-servers.json /app/mcp-servers.json
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["/docker-entrypoint.sh"]
