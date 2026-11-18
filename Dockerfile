# Construire l'API avec les dépendances de développement.
FROM node:22-alpine AS build

WORKDIR /app

# Copier d'abord les dépendances pour profiter du cache Docker.
COPY package.json package-lock.json .npmrc ./
RUN npm ci

COPY . .
RUN npm run build && npm prune --omit=dev

# Exécuter l'API avec les seules dépendances de production.
FROM node:22-alpine AS runtime

ENV NODE_ENV=production
WORKDIR /app

COPY --from=build --chown=node:node /app/package.json ./
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist

USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
