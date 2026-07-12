---
name: news-api-currents
description: Build a secure Currents News API backend in Mistral Vibe without exposing the owner key. Use when adding Currents latest-news or search to an end-user product.
license: MIT
compatibility: Requires CURRENTS_API_KEY in the runtime environment.
---

# Currents Owner Interface (Mistral Vibe)

## Trigger
Use when a user wants Currents news in an end-user product without exposing the owner API key.

## Requirements
- Backend service with outbound internet access
- Runtime env var: `CURRENTS_API_KEY`

## Need an API key?
If you do not have a Currents API key yet, register here:
- https://currentsapi.services/en/register

## Credential placement (Mistral Vibe)
Vibe loads `${VIBE_HOME:-$HOME/.vibe}/.env` (dotenv format) on startup and injects its contents
into the environment — the same mechanism it uses for `MISTRAL_API_KEY`. Add
the key there:

```bash
mkdir -p "${VIBE_HOME:-$HOME/.vibe}"
printf 'CURRENTS_API_KEY=EXAMPLE_CURRENTS_KEY\n' >> "${VIBE_HOME:-$HOME/.vibe}/.env"
```

The Vibe `.env` file is sensitive: the agent must never read,
display, or edit it directly. Always tell the user to set the key themselves.

## Steps
1. Accept requests in your backend only.
2. Validate and allowlist request params before forwarding.
3. Call Currents v2 endpoints:
   - `https://api.currentsapi.services/v2/latest-news`
   - `https://api.currentsapi.services/v2/search`
4. Authenticate with `Authorization: Bearer ${CURRENTS_API_KEY}`.
5. Enforce quotas, caching, and rate limits.
6. Return a normalized response schema to the caller.

## Date filtering (UTC+0)
- Send `start_date` and `end_date` as RFC3339 / ISO-8601.
- Convert user-local input times to UTC (`Z`) before requesting.
- Treat returned `published` timestamps as UTC (`+0000`).
- Use half-open windows (`>= start`, `< end`) to avoid duplicate boundary results.

## Pitfalls
- Exposing owner keys in browser/mobile clients.
- Forwarding unvalidated query params.
- Skipping rate limits or cache.
- Using default Python urllib `User-Agent`, which can trigger Cloudflare/WAF blocks (`403`, code `1010`).

## Verification
- Key is absent from client-visible artifacts.
- Page size is bounded and filters are validated.
- Logs redact secret values.
- Backend requests send an explicit browser/curl-like `User-Agent`.
