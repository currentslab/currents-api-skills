# Currents API Skills

<p align="center">
  <strong>Bring secure Currents News API workflows to your AI agent—in one command.</strong>
</p>

<p align="center">
  Install-ready skills for OpenAI Codex, Hermes, OpenClaw, OpenCode, Mistral
  Vibe, Goose, OpenHands, and AgentSkills-compatible runtimes.
</p>

<p align="center">
  <a href="https://currentsapi.services/en/register">Get an API key</a>
  ·
  <a href="#one-line-install">Install the skill</a>
  ·
  <a href="#restart-your-agent-and-use-the-skill">Try an example prompt</a>
</p>

Use `news-api-currents` to help agents build latest-news feeds, search
endpoints, backend proxies, and Currents-powered integrations without exposing
`CURRENTS_API_KEY` to browser or mobile clients.

## Why use it?

- **Secure by design:** keep credentials server-side and redact secrets from logs.
- **Runtime-ready:** install the package tailored to your agent environment.
- **Production-minded:** validate filters, bound page sizes, cache responses, and enforce rate limits.

> One skill, multiple runtimes. Every package under `targets/` follows the same
> secure integration model while adapting its guidance to the target agent.

## Supported runtimes

| Target | Install command | Destination |
|---|---|---|
| Hermes Agent | `./install.sh hermes` | `~/.hermes/skills/research/news-api-currents/` |
| OpenClaw | `./install.sh openclaw` | `~/.openclaw/skills/news-api-currents/` |
| OpenCode | `./install.sh opencode` | `~/.config/opencode/skills/news-api-currents/` |
| Mistral Vibe | `./install.sh vibe` | `$VIBE_HOME/skills/news-api-currents/` (defaults to `~/.vibe`) |
| OpenHands | `./install.sh openhands` | `~/.openhands/skills/news-api-currents/` |
| OpenAI Codex / Goose / Generic AgentSkills | `./install.sh codex` \| `goose` \| `agentskills` | `~/.agents/skills/news-api-currents/` |

> Codex, Goose, and generic AgentSkills all discover the same portable package
> from `~/.agents/skills`. Use whichever target name matches your runtime;
> installing more than one is a no-op.

---

## One-line install

For OpenAI Codex:

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- codex
```

Replace `codex` with any target from the table above. For example:

```bash
# Mistral Vibe
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- vibe

# OpenHands
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- openhands
```

If no target is supplied, the installer defaults to Hermes:

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash
```

> Streamed installs copy files. To use `--link`, install from a local checkout
> so the symlink has a persistent source directory.

---

## Clone + install

If you prefer to keep a local checkout:

```bash
git clone https://github.com/currentslab/currents-api-skills.git
cd currents-api-skills
./install.sh hermes
```

Replace `hermes` with one of:
- `openclaw`
- `opencode`
- `codex`
- `vibe`
- `goose`
- `openhands`
- `agentskills`
- `all`

`all` installs each non-overlapping destination once. Since `codex`, `goose`,
and `agentskills` share one destination, `all` installs that shared package a
single time instead of three times.

To symlink instead of copy:

```bash
./install.sh hermes --link
```

---

## Set your API key

```bash
export CURRENTS_API_KEY="EXAMPLE_CURRENTS_KEY"
```

If your agent uses a persistent env file, put the key there instead.

Hermes example:

```bash
printf 'CURRENTS_API_KEY=EXAMPLE_CURRENTS_KEY\n' >> ~/.hermes/.env
```

Mistral Vibe example:

```bash
mkdir -p "${VIBE_HOME:-$HOME/.vibe}"
printf 'CURRENTS_API_KEY=EXAMPLE_CURRENTS_KEY\n' >> "${VIBE_HOME:-$HOME/.vibe}/.env"
```

Need a Currents API key?
- https://currentsapi.services/en/register

---

## Restart your agent and use the skill

Example prompts:
- "Use `news-api-currents` to design a safe backend proxy for Currents API."
- "Use `news-api-currents` to build a latest-news endpoint with caching and rate limits."
- "Use `news-api-currents` to add Currents search with UTC date filtering."

---

## Repo layout

```text
currents-api-skills/
├── README.md
├── install.sh
├── examples/
│   └── openclaw/
│       └── openclaw.skills.currents.json5
└── targets/
    ├── agentskills/
    │   └── news-api-currents/
    │       ├── SKILL.md
    │       └── agents/
    │           └── openai.yaml   # also used by the codex/goose targets
    ├── hermes/
    │   └── news-api-currents/
    │       └── SKILL.md
    ├── openclaw/
    │   └── news-api-currents/
    │       └── SKILL.md
    ├── opencode/
    │   └── news-api-currents/
    │       └── SKILL.md
    ├── vibe/
    │   └── news-api-currents/
    │       └── SKILL.md
    └── openhands/
        └── news-api-currents/
            └── SKILL.md
```

---

## Manual install

If you prefer to copy the folder yourself instead of using `install.sh`:

### Hermes Agent

```bash
mkdir -p ~/.hermes/skills/research
cp -R targets/hermes/news-api-currents ~/.hermes/skills/research/
```

### OpenClaw

```bash
mkdir -p ~/.openclaw/skills
cp -R targets/openclaw/news-api-currents ~/.openclaw/skills/
```

### OpenCode

```bash
mkdir -p ~/.config/opencode/skills
cp -R targets/opencode/news-api-currents ~/.config/opencode/skills/
```

### Mistral Vibe

```bash
mkdir -p "${VIBE_HOME:-$HOME/.vibe}/skills"
cp -R targets/vibe/news-api-currents "${VIBE_HOME:-$HOME/.vibe}/skills/"
```

### OpenHands

```bash
mkdir -p ~/.openhands/skills
cp -R targets/openhands/news-api-currents ~/.openhands/skills/
```

### OpenAI Codex / Goose / Generic AgentSkills runtimes

```bash
mkdir -p ~/.agents/skills
cp -R targets/agentskills/news-api-currents ~/.agents/skills/
```

---

## OpenClaw example config

An example OpenClaw config fragment is included at:

```text
examples/openclaw/openclaw.skills.currents.json5
```

It shows one way to wire:
- `CURRENTS_API_KEY`
- an explicit `CURRENTS_HTTP_USER_AGENT`
- Docker sandbox env passthrough

---

## Validation

```bash
./tests/test_install.sh
./tests/validate_skills.sh
```

Set `RUN_NETWORK_TESTS=1` when running `test_install.sh` to also verify streamed
installation from a commit SHA and confirm that streamed `--link` attempts
preserve an existing installation.

---

## What the skill helps with

All variants are designed around the same safe usage model:
- keep the Currents API key on the backend,
- validate and allowlist incoming params,
- add caching and rate limits,
- normalize the returned response shape,
- use UTC-safe date filtering,
- avoid Cloudflare/WAF issues by sending an explicit browser-like or curl-like `User-Agent`.

---

## Notes

- This repo contains **skill packages**, not a standalone application.
- The installer copies or symlinks the skill into your local agent directory.
- After installation, restart your agent so it can discover the new skill.
