#!/bin/bash
set -e

docker-compose run --rm dev bash -c "
    mkdir -p build &&
    cd build &&
    cmake -G Ninja .. &&
    ninja
"