# ---- Builder stage ----
FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json ./
RUN npm install

COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build

# ---- Runtime stage ----
FROM node:18-alpine

WORKDIR /app

COPY package.json ./
RUN npm install --omit=dev

COPY --from=builder /app/dist/ ./dist/
COPY lib/ ./lib/

RUN chown -R node:node /app

USER node

ENV PORT=3200
ENV WIKIJS_BASE_URL=http://localhost:3000
ENV WIKIJS_TOKEN=""

EXPOSE 3200

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3200/health || exit 1

ENTRYPOINT ["node", "lib/fixed_mcp_http_server.js"]
