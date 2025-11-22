#!/bin/bash
set -euo pipefail

# Fail if required env var missing
: "${POSTGRES_SUPER_PASS?}"

cd "$(dirname "$0")/../../.."
docker compose up -d postgres