# Build stage
FROM node:18.20.0-alpine3.19 AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++ openssl-dev

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy prisma schema and generate
COPY prisma ./prisma/
RUN npx prisma generate

# Production stage  
FROM node:18.20.0-alpine3.19

# Install runtime dependencies
RUN apk add --no-cache openssl libgcc libstdc++ && \
    rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force && \
    rm -rf /root/.npm /tmp/*

# Copy only Prisma client from builder
COPY --from=builder /app/node_modules/.prisma/client ./node_modules/.prisma/client
COPY --from=builder /app/node_modules/@prisma/client ./node_modules/@prisma/client

# Strip Prisma binaries
RUN find /app/node_modules/.prisma/client -name "*.node" -exec strip {} \; 2>/dev/null || true

# Copy application code
COPY --chown=nodejs:nodejs src ./src
COPY --chown=nodejs:nodejs prisma ./prisma
COPY --chown=nodejs:nodejs public ./public

# Create upload directories
RUN mkdir -p public/images/movies public/images/tv_series && \
    chown -R nodejs:nodejs public/images

USER nodejs

EXPOSE 8080

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["node", "src/server.js"]
