#!/bin/bash

set -e
set -x
bash generate.sh

docker build . -t docs

nohup docker run -p 127.0.0.1:8000:8000 docs &

