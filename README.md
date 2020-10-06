# docker-node

## Description

Docker container based on [cimg-node](https://github.com/CircleCI-Public/cimg-node) used across Synthetix repositories.

## Generating dockerfiles

Is as simple as running:

`npm run generate <node_version> <arch>` inside `shared` folder:

* single dockerfile: `npm run generate 12.18 amd64`
* multiple dockerfiles: `npm run generate 10.22,12.18,14.13 amd64`
* without locking sha256 version: `npm run generate 12.18`
