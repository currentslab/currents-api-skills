# Currents API Skills Collection

Install-ready skill packages for using the **Currents News API** safely inside multiple AI agent runtimes.

This repository is for people who want to:
- add a reusable `news-api-currents` skill to their agent,
- keep `CURRENTS_API_KEY` server-side,
- get a clean starting point for building Currents-powered tools, proxies, and integrations.

## What is in this repo?

Each folder under `targets/` contains a ready-to-install version of the same skill adapted for a specific agent runtime.

| Target | Install command | Destination |
|---|---|---|
| Hermes Agent | `./install.sh hermes` | `~/.hermes/skills/research/news-api-currents/` |
| OpenClaw | `./install.sh openclaw` | `~/.openclaw/skills/news-api-currents/` |
| OpenCode | `./install.sh opencode` | `~/.config/opencode/skills/news-api-currents/` |
| Goose | `./install.sh goose` | `~/.agents/skills/news-api-currents/` |
| OpenHands | `./install.sh openhands` | `~/.openhands/skills/news-api-currents/` |
| Generic AgentSkills runtimes | `./install.sh agentskills` | `~/.agents/skills/news-api-currents/` |

---

## One-line install

The installer now supports direct `curl | bash` usage.
If you do not pass a target, it defaults to **Hermes**.

### Hermes

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash
```

Equivalent explicit form:

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- hermes
```

### OpenClaw

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- openclaw
```

### OpenCode

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- opencode
```

### Other runtimes

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- goose
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- openhands
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- agentskills
```

To symlink instead of copy:

```bash
curl -fsSL https://raw.githubusercontent.com/currentslab/currents-api-skills/master/install.sh | bash -s -- hermes --link
```

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
- `goose`
- `openhands`
- `agentskills`

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
    │       └── SKILL.md
    ├── goose/
    │   └── news-api-currents/
    │       └── SKILL.md
    ├── hermes/
    │   └── news-api-currents/
    │       └── SKILL.md
    ├── openclaw/
    │   └── news-api-currents/
    │       └── SKILL.md
    ├── opencode/
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

### Goose

```bash
mkdir -p ~/.agents/skills
cp -R targets/goose/news-api-currents ~/.agents/skills/
```

### OpenHands

```bash
mkdir -p ~/.openhands/skills
cp -R targets/openhands/news-api-currents ~/.openhands/skills/
```

### Generic AgentSkills runtimes

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
