#!/usr/bin/env bash
set -euo pipefail

# Install Currents API skill variants from this collection.
#
# Works both locally and over curl:
#   bash install.sh hermes
#   bash install.sh openhands --link
#   curl -fsSL https://<host>/install.sh | bash -s -- hermes
#   curl -fsSL https://<host>/install.sh | bash -s -- all

TARGET="${1:-}"
MODE="copy"
if [[ "${2:-}" == "--link" ]]; then
  MODE="link"
fi

resolve_root() {
  if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
    return 0
  fi

  if [[ -d "./targets" && -f "./README.md" ]]; then
    pwd
    return 0
  fi

  cat >&2 <<'EOF'
Unable to locate repository root automatically.

For curl-piped installs, first clone the repo locally, then run one of:
  git clone <repo-url>
  cd currents-api-skills-collections
  curl -fsSL <raw-install-script-url> | bash -s -- hermes

The piped installer expects to run from inside the cloned repository so it can copy the target folders.
EOF
  exit 2
}

ROOT="$(resolve_root)"

install_one() {
  local target="$1"
  local src=""
  local dest=""

  case "$target" in
    hermes)
      src="$ROOT/targets/hermes/news-api-currents"
      dest="$HOME/.hermes/skills/research/news-api-currents"
      ;;
    openclaw)
      src="$ROOT/targets/openclaw/news-api-currents"
      dest="$HOME/.openclaw/skills/news-api-currents"
      ;;
    opencode)
      src="$ROOT/targets/opencode/news-api-currents"
      dest="$HOME/.config/opencode/skills/news-api-currents"
      ;;
    goose)
      src="$ROOT/targets/goose/news-api-currents"
      dest="$HOME/.agents/skills/news-api-currents"
      ;;
    openhands)
      src="$ROOT/targets/openhands/news-api-currents"
      dest="$HOME/.openhands/skills/news-api-currents"
      ;;
    agentskills)
      src="$ROOT/targets/agentskills/news-api-currents"
      dest="$HOME/.agents/skills/news-api-currents"
      ;;
    *)
      echo "Unknown target: $target" >&2
      return 2
      ;;
  esac

  if [[ ! -d "$src" ]]; then
    echo "Source skill directory not found: $src" >&2
    return 2
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ "$MODE" == "link" ]]; then
    rm -rf "$dest"
    ln -s "$src" "$dest"
    echo "Linked [$target]: $dest -> $src"
  else
    rm -rf "$dest"
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"/
    echo "Installed [$target]: $src -> $dest"
  fi
}

case "$TARGET" in
  hermes|openclaw|opencode|goose|openhands|agentskills)
    install_one "$TARGET"
    ;;
  all)
    install_one hermes
    install_one openclaw
    install_one opencode
    install_one goose
    install_one openhands
    ;;
  *)
    echo "Usage: $0 {hermes|openclaw|opencode|goose|openhands|agentskills|all} [--link]" >&2
    echo "curl usage: curl -fsSL <install-script-url> | bash -s -- <target> [--link]" >&2
    exit 2
    ;;
esac

echo "Done."
