# this layer is only for development
FROM node:20 AS base
RUN apt update && apt upgrade -y && npm i -g npm yarn --force
RUN apt install -y python3 g++ build-essential
RUN yarn config set python $(which python3)
# dev layer include git cli
FROM base AS dev
RUN apt install git -y
# build layer responsible to build app
FROM dev AS build
WORKDIR /app
COPY app/ .
RUN yarn install && yarn tsc && yarn build:backend

# original docker file section
FROM node:20-bookworm-slim AS shippment

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update && \
  apt-get install -y --no-install-recommends python3 g++ build-essential && \
  yarn config set python /usr/bin/python3

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get update && \
#   apt-get install -y --no-install-recommends libsqlite3-dev

# From here on we use the least-privileged `node` user to run the backend.
USER node

# This should create the app dir AS `node`.
# If it is instead created AS `root` then the `tar` command below will fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`) so the app dir is correctly created AS `node`.
WORKDIR /app

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV production

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
  yarn install --frozen-lockfile --production --network-timeout 300000

# Then copy the rest of the backend bundle, along with any other files we might want.
COPY --from=build --chown=node:node /app/packages/backend/dist/bundle.tar.gz /app/app-config*.yaml ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
