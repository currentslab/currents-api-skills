#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

assert_file() {
  if [[ ! -f "$1" ]]; then
    echo "Expected file not found: $1" >&2
    exit 1
  fi
}

test_target() {
  local target="$1"
  local relative_path="$2"
  local home="$TEMP_ROOT/$target-home"
  mkdir -p "$home"

  HOME="$home" bash "$ROOT/install.sh" "$target" >/dev/null
  assert_file "$home/$relative_path/SKILL.md"
}

test_target hermes ".hermes/skills/research/news-api-currents"
test_target openclaw ".openclaw/skills/news-api-currents"
test_target opencode ".config/opencode/skills/news-api-currents"
test_target openhands ".openhands/skills/news-api-currents"

# Codex, Goose, and generic AgentSkills all discover skills from the same
# ~/.agents/skills directory, so they must resolve to the exact same package.
# Install them one after another into the same $HOME and make sure the later
# installs never destroy files (like Codex's agents/openai.yaml) that an
# earlier install put there.
shared_home="$TEMP_ROOT/agents-shared-home"
mkdir -p "$shared_home"
shared_dest="$shared_home/.agents/skills/news-api-currents"
for shared_target in codex goose agentskills; do
  HOME="$shared_home" bash "$ROOT/install.sh" "$shared_target" >/dev/null
  assert_file "$shared_dest/SKILL.md"
  assert_file "$shared_dest/agents/openai.yaml"
done

vibe_home="$TEMP_ROOT/vibe-custom-home"
mkdir -p "$vibe_home" "$TEMP_ROOT/vibe-user-home"
HOME="$TEMP_ROOT/vibe-user-home" VIBE_HOME="$vibe_home" \
  bash "$ROOT/install.sh" vibe >/dev/null
assert_file "$vibe_home/skills/news-api-currents/SKILL.md"

all_home="$TEMP_ROOT/all-home"
all_vibe_home="$TEMP_ROOT/all-vibe-home"
mkdir -p "$all_home" "$all_vibe_home"
HOME="$all_home" VIBE_HOME="$all_vibe_home" \
  bash "$ROOT/install.sh" all >/dev/null
assert_file "$all_home/.hermes/skills/research/news-api-currents/SKILL.md"
assert_file "$all_home/.openclaw/skills/news-api-currents/SKILL.md"
assert_file "$all_home/.config/opencode/skills/news-api-currents/SKILL.md"
assert_file "$all_home/.openhands/skills/news-api-currents/SKILL.md"
assert_file "$all_home/.agents/skills/news-api-currents/SKILL.md"
assert_file "$all_home/.agents/skills/news-api-currents/agents/openai.yaml"
assert_file "$all_vibe_home/skills/news-api-currents/SKILL.md"
grep -q 'Currents Owner Interface (Portable)' \
  "$all_home/.agents/skills/news-api-currents/SKILL.md"

link_home="$TEMP_ROOT/link-home"
mkdir -p "$link_home"
HOME="$link_home" bash "$ROOT/install.sh" hermes --link >/dev/null
link_path="$link_home/.hermes/skills/research/news-api-currents"
if [[ ! -L "$link_path" || ! -e "$link_path/SKILL.md" ]]; then
  echo "Local link install did not create a resolvable skill." >&2
  exit 1
fi

if [[ "${RUN_NETWORK_TESTS:-0}" == "1" ]]; then
  ref="$(git -C "$ROOT" rev-parse HEAD)"
  remote_home="$TEMP_ROOT/remote-home"
  remote_work="$TEMP_ROOT/remote-work"
  mkdir -p "$remote_home" "$remote_work"

  (
    cd "$remote_work"
    HOME="$remote_home" bash -s -- hermes --ref "$ref" < "$ROOT/install.sh" >/dev/null
  )
  assert_file "$remote_home/.hermes/skills/research/news-api-currents/SKILL.md"

  protected_home="$TEMP_ROOT/protected-home"
  protected_work="$TEMP_ROOT/protected-work"
  mkdir -p "$protected_home" "$protected_work"
  protected_dest="$protected_home/.hermes/skills/research/news-api-currents"
  mkdir -p "$protected_dest"
  touch "$protected_dest/existing-install"

  set +e
  (
    cd "$protected_work"
    HOME="$protected_home" bash -s -- hermes --link --ref "$ref" < "$ROOT/install.sh"
  ) >/dev/null 2>&1
  link_status=$?
  set -e

  if [[ "$link_status" -eq 0 ]]; then
    echo "Streamed --link unexpectedly succeeded." >&2
    exit 1
  fi
  assert_file "$protected_dest/existing-install"
fi

echo "Installer tests passed."
