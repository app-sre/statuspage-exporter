#!/bin/bash

export TAG="pr-$(git rev-parse --short HEAD)"
make container-test image
