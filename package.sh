#!/bin/bash

LAMBDA_DIR=$1

cd "$LAMBDA_DIR"
pip3 install -r requirements.txt -t .
zip -r ./"${LAMBDA_DIR}.zip" .
cd ..
