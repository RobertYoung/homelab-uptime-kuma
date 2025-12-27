#!/bin/sh

echo "deploy hook executed for domain: $RENEWED_LINEAGE"

docker kill -s HUP nginx

echo "deploy hook completed for domain: $RENEWED_LINEAGE"