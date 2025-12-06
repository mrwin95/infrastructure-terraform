# ---- Build stage ----
FROM node:22-alpine AS build

WORKDIR /app

# Install deps
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* .npmrc* ./ 2>/dev/null || true

# Prefer pnpm/yarn if you want, keeping it simple with npm here
RUN npm install

COPY tsconfig.json ./tsconfig.json
COPY src ./src

RUN npm run build

# ---- Runtime stage ----
FROM node:22-alpine AS runtime

WORKDIR /app

# Copy only what's needed to run
COPY package.json ./
RUN npm install --omit=dev

COPY --from=build /app/dist ./dist

ENV NODE_ENV=production

CMD ["node", "dist/index.js"]