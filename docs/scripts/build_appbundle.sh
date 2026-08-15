#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${YARNGPT_API_KEY:-}" ]]; then
  echo "YARNGPT_API_KEY is not set. Export it before running this script."
  exit 1
fi

flutter build appbundle --dart-define=YARNGPT_API_KEY="$YARNGPT_API_KEY"