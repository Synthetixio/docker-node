# docker-node

## Description

Docker containers based on [cimg-node](https://github.com/CircleCI-Public/cimg-node) and official [node](https://hub.docker.com/_/node) images used across Synthetix repositories.

## Generating dockerfiles

Is as simple as running:

`npm run generate <node_version> <distro> <arch>` inside `shared` folder:

* single dockerfile: `npm run generate 12.18 alpine amd64`
* multiple dockerfiles: `npm run generate 10.22,12.18,14.13 alpine,buster-slim amd64`
* without locking sha256 version: `npm run generate 12.18`
