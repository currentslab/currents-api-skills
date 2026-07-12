#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v uvx >/dev/null 2>&1; then
  echo "uvx is required to run the official Agent Skills validator." >&2
  exit 2
fi

for skill_dir in "$ROOT"/targets/*/news-api-currents; do
  uvx --from skills-ref agentskills validate "$skill_dir"
done

echo "All skills are valid."
