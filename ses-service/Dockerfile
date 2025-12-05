FROM  node:22-alpine AS builder

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

COPY  package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY ./ ./

RUN pnpm build

FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV AWS_REGION=ap-northeast-1

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

CMD [ "node", "dist/index.js" ]