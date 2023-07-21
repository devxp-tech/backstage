# this layer is only for development
FROM node:18 as base
RUN apt update && apt upgrade -y && npm i -g npm yarn --force
# dev layer include git cli
FROM base as dev
RUN apt install git -y
# build layer responsible to build app
FROM dev as build
WORKDIR /app
COPY app/ .
RUN yarn install 
RUN yarn tsc 
RUN yarn build:backend
# prd layer install only production stuff

FROM node:18-bullseye-slim
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 build-essential && \
    yarn config set python /usr/bin/python3
USER node
WORKDIR /app
ENV NODE_ENV production
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --frozen-lockfile --production --network-timeout 300000

# Then copy the rest of the backend bundle, along with any other files we might want.
COPY --from=build --chown=node:node /app/packages/backend/dist/bundle.tar.gz /app/app-config*.yaml ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]



# COPY --from=build app/packages/backend/dist/bundle.tar.gz .
# COPY --from=build app/packages/backend/dist/skeleton.tar.gz .
# COPY --from=build app/app-config.yaml .
# COPY --from=build app/app-config.production.yaml .
# RUN tar xfz bundle.tar.gz
# RUN tar xfz skeleton.tar.gz
# RUN rm skeleton.tar.gz bundle.tar.gz
# RUN yarn install --frozen-lockfile --production --network-timeout 300000 && rm -rf "$(yarn cache dir)"

# #shipment responsible to pack only needed code
# FROM node:18-alpine as shipment
# WORKDIR /app
# COPY --from=prd --chown=node:node /app .
# CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
