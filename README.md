# docker-node

![Docker Image (library/node) CI](https://github.com/Synthetixio/docker-node/workflows/Docker%20Image%20(library/node)%20CI/badge.svg)

## Description

Docker containers based on official [node](https://hub.docker.com/_/node) images used across Synthetix repositories for CI purposes.

## Updating versions

Take a look at [config.json](https://github.com/Synthetixio/docker-node/blob/master/config.json) file.

## Generating dockerfiles

Is as simple as running:

1. `cd shared`
2. `npm install`
3. `npm run generate`
