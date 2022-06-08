# this layer is only for development
FROM node:16 as base
RUN apt update && apt upgrade -y
# dev layer include git cli
FROM base as dev
RUN apt install git -y
# build layer responsible to build app
FROM dev as build
WORKDIR /app
COPY app/ .
RUN yarn install && yarn tsc && yarn build
# prd layer install only production stuff
FROM dev as prd
WORKDIR /app
COPY --from=build app/packages/backend/dist/bundle.tar.gz .
COPY --from=build app/packages/backend/dist/skeleton.tar.gz .
COPY --from=build app/app-config.yaml .
COPY --from=build app/app-config.production.yaml .
RUN tar xfz bundle.tar.gz
RUN tar xfz skeleton.tar.gz
RUN rm skeleton.tar.gz bundle.tar.gz
RUN yarn install --frozen-lockfile --production --network-timeout 300000 && rm -rf "$(yarn cache dir)"

#shipment responsible to pack only needed code
FROM node:16-alpine as shipment
WORKDIR /app
COPY --from=prd --chown=node:node /app .
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
