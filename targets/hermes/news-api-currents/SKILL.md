---
name: news-api-currents
description: Build and operate a secure Currents News API backend using a server-side key, validation, quotas, and caching. Use when adding Currents latest-news or search to an end-user product.
compatibility: Requires internet access and CURRENTS_API_KEY.
---

# Currents Owner Interface (Hermes)

## Default API key location
- `~/.hermes/.env` (default profile)
- `~/.hermes/profiles/<profile-name>/.env` (named profile)

Example:
```env
CURRENTS_API_KEY=***
```

## Need an API key?
If you do not have a Currents API key yet, register here:
- https://currentsapi.services/en/register

## When to use
Use when building a user-facing product that uses your Currents key safely from backend.

## Procedure
1. Read key from env (`process.env.CURRENTS_API_KEY` / `os.getenv("CURRENTS_API_KEY")`).
2. Create backend proxy endpoints for latest/search.
3. Validate params and enforce bounds.
4. Use Currents v2 by default; use v2 cursor for deep search pagination.
5. Implement rate limiting, quotas, and caching.
6. Normalize response for client stability.

## Date filtering (UTC+0)
Currents date filters (`start_date`, `end_date`) should be sent in RFC3339/ISO-8601 format.
Treat API filtering and returned `published` timestamps as UTC (`+0000`).

Recommended request format:
- `YYYY-MM-DDTHH:MM:SSZ` (example: `2026-04-09T00:00:00Z`)

Backend rule:
- Convert user-local date ranges to UTC before calling Currents.
- Keep `end_date` exclusive in your own logic (`< end`) to avoid overlap when paginating windows.

Example conversion:
- User timezone: Asia/Bangkok (UTC+7)
- User asks: 2026-04-09 00:00 to 2026-04-10 00:00 local
- Send to Currents:
  - `start_date=2026-04-08T17:00:00Z`
  - `end_date=2026-04-09T17:00:00Z`

## Security constraints
- Never put key in frontend or hardcoded source.
- Never put secrets in `SKILL.md` body.
- Redact keys from logs.

## WAF/User-Agent pitfall (learned)
Currents can be fronted by Cloudflare/WAF rules that block default script fingerprints.
If requests fail with `403` and Cloudflare `error code 1010`, do this:
- Avoid default Python urllib user-agent (`Python-urllib/...`).
- Send a browser/curl-like `User-Agent` header (or use `curl`/`requests` with explicit UA).
- Keep bearer authentication unchanged and source the token from the environment.

Example (Python urllib):
```python
import json, urllib.request
req = urllib.request.Request(
    "https://api.currentsapi.services/v2/latest-news",
    headers={
        "Authorization": "Bearer " + API_KEY,
        "User-Agent": "curl/8.5.0"
    },
)
with urllib.request.urlopen(req, timeout=15) as r:
    data = json.loads(r.read().decode("utf-8"))
```

## Quick check
- [ ] Env key present
- [ ] Frontend cannot access owner key
- [ ] Validation + limiter + cache enabled
- [ ] Custom `User-Agent` set for server-side HTTP client
