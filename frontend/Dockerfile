# ------------------------------------------------------------------------------
# 1. Base Build Stage
# - --platform=$BUILDPLATFORM: Runs on native builder CPU (avoids slow QEMU emulation in multi-arch builds)
# - node:22.14.0-alpine: Lightweight Alpine-based Node.js runtime
# - @sha256:...: Cryptographic hash pin for reproducible, secure builds (prevents tag tampering)
# - AS builder: Labels this stage so static assets can be copied in later stages
# ------------------------------------------------------------------------------

FROM --platform=$BUILDPLATFORM node:22.14.0-alpine@sha256:9bef0ef1e268f60627da9ba7d7605e8831d5b56ad07487d24d1aa386336d1944 AS builder

WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Install dependencies with BuildKit cache mount (Fast BuildKit-cached dependency install)
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline --no-audit --no-fund

# Copy source code and build
COPY . .
ENV NODE_ENV=production
RUN npm run build
