#!/usr/bin/env bash
set -euo pipefail

# Install Currents API skill variants from this collection.
#
# Works both locally and over curl:
#   bash install.sh
#   bash install.sh openclaw
#   bash install.sh hermes --link
#   curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- openclaw

REPO_OWNER="currentslab"
REPO_NAME="currents-api-skills"
REPO_REF="master"
TARGET="hermes"
MODE="copy"
REMOTE_TMP=""
ROOT=""

usage() {
  cat <<EOF
Usage: $0 [target] [--link] [--ref <git-ref>]

Targets:
  hermes      Install to ~/.hermes/skills/research/news-api-currents
  openclaw    Install to ~/.openclaw/skills/news-api-currents
  opencode    Install to ~/.config/opencode/skills/news-api-currents
  vibe        Install to \${VIBE_HOME:-~/.vibe}/skills/news-api-currents (Mistral Vibe)
  openhands   Install to ~/.openhands/skills/news-api-currents
  codex       Install to ~/.agents/skills/news-api-currents (OpenAI Codex)
  goose       Install to ~/.agents/skills/news-api-currents (Goose)
  agentskills Install to ~/.agents/skills/news-api-currents (generic AgentSkills)
              codex, goose, and agentskills share one package and one
              destination since all three read skills from ~/.agents/skills.
  all         Install every non-overlapping destination once

Options:
  --link      Symlink from a local checkout instead of copying files
  --ref REF   Install from a different git ref when running via curl|bash
  -h, --help  Show this help

Examples:
  bash install.sh
  bash install.sh openclaw --link
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_REF}/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_REF}/install.sh | bash -s -- openhands
EOF
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

cleanup() {
  if [[ -n "$REMOTE_TMP" && -d "$REMOTE_TMP" ]]; then
    rm -rf "$REMOTE_TMP"
  fi
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    hermes|openclaw|opencode|codex|vibe|goose|openhands|agentskills|all)
      TARGET="$1"
      ;;
    --link)
      MODE="link"
      ;;
    --copy)
      MODE="copy"
      ;;
    --ref)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --ref" >&2
        usage >&2
        exit 2
      fi
      REPO_REF="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

fetch_remote_root() {
  local archive_url
  local encoded_ref=""
  local char=""
  local i

  for ((i = 0; i < ${#REPO_REF}; i++)); do
    char="${REPO_REF:i:1}"
    case "$char" in
      [a-zA-Z0-9.~_-]) encoded_ref+="$char" ;;
      *)
        printf -v char '%%%02X' "'$char"
        encoded_ref+="$char"
        ;;
    esac
  done

  archive_url="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/${encoded_ref}"
  REMOTE_TMP="$(mktemp -d)"

  echo "Fetching ${REPO_OWNER}/${REPO_NAME}@${REPO_REF}..." >&2
  if have_cmd curl; then
    curl -fsSL "$archive_url" | tar -xzf - -C "$REMOTE_TMP"
  elif have_cmd wget; then
    wget -qO- "$archive_url" | tar -xzf - -C "$REMOTE_TMP"
  else
    echo "Need curl or wget for remote install." >&2
    exit 2
  fi

  local candidate
  for candidate in "$REMOTE_TMP"/*; do
    if [[ -d "$candidate/targets" && -f "$candidate/install.sh" ]]; then
      ROOT="$candidate"
      return 0
    fi
  done

  echo "Downloaded archive is missing a valid repository root." >&2
  exit 2
}

resolve_root() {
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -d "$script_dir/targets" ]]; then
      ROOT="$script_dir"
      return 0
    fi
  fi

  if [[ -d "./targets" && -f "./README.md" ]]; then
    ROOT="$(pwd)"
    return 0
  fi

  fetch_remote_root
}

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
    vibe)
      src="$ROOT/targets/vibe/news-api-currents"
      dest="${VIBE_HOME:-$HOME/.vibe}/skills/news-api-currents"
      ;;
    openhands)
      src="$ROOT/targets/openhands/news-api-currents"
      dest="$HOME/.openhands/skills/news-api-currents"
      ;;
    codex|goose|agentskills)
      # Codex, Goose, and generic AgentSkills runtimes all discover user
      # skills from the same ~/.agents/skills directory, so they must share
      # one physical package. Installing any of these three names installs
      # the identical files; picking one after another is a no-op, not a
      # silent overwrite of different content.
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

  if [[ "$MODE" == "link" && -n "$REMOTE_TMP" ]]; then
    echo "--link requires a local checkout; streamed installs use --copy." >&2
    return 2
  fi

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"

  if [[ "$MODE" == "link" ]]; then
    ln -s "$src" "$dest"
    echo "Linked [$target]: $dest -> $src"
  else
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"/
    echo "Installed [$target]: $src -> $dest"
  fi
}

resolve_root

case "$TARGET" in
  hermes|openclaw|opencode|codex|vibe|goose|openhands|agentskills)
    install_one "$TARGET"
    ;;
  all)
    install_one hermes
    install_one openclaw
    install_one opencode
    install_one vibe
    install_one openhands
    # Codex and Goose both discover the portable package from ~/.agents/skills.
    install_one agentskills
    ;;
  *)
    echo "Unknown target: $TARGET" >&2
    usage >&2
    exit 2
    ;;
esac

echo "Done."
