---
name: news-api-currents
description: Build a secure Currents News API backend in OpenClaw with validated proxy routes, quotas, and caching. Use when adding Currents latest-news or search without exposing the owner key.
compatibility: Requires CURRENTS_API_KEY in the runtime environment.
---

# Currents Owner Interface (OpenClaw)

## When to use
Use when you are the API owner and want end-users to consume Currents through your product without exposing owner credentials.

## Core policy
- Never expose owner key in browser/mobile clients.
- Currents calls must go backend -> Currents only.
- Read the key from the environment (`CURRENTS_API_KEY`).

## Need an API key?
If you do not have a Currents API key yet, register here:
- https://currentsapi.services/en/register

## Procedure
1. Build backend endpoints:
   - `POST /api/news/latest`
   - `POST /api/news/search`
2. Validate/allowlist query params (`keywords`, `query`, `language`, `country`, `category`, `start_date`, `end_date`, `domain`, `domain_not`, `author`, `page_size`, `page_number`, `cursor`).
3. Use safe defaults (`language=en`, `page_size=10`, max `page_size<=100`).
4. Call Currents v2 endpoints with `Authorization: Bearer ${CURRENTS_API_KEY}`.
5. Enforce per-user + per-IP rate limits and product quotas.
6. Add cache:
   - latest-news TTL: 30-120s
   - search TTL: 5-30m
7. Normalize response to stable schema (`status`, `items`, `pagination`, `meta`).

## Date filtering (UTC+0)
- `start_date` and `end_date` should be RFC3339 / ISO-8601 parseable.
- Treat Currents filters and returned `published` values as UTC (`+0000`).
- Convert user-local date ranges to UTC in backend before request.
- Prefer half-open ranges in your app logic: `published >= start_date` and `published < end_date`.

Example:
- Local (UTC+7): `2026-04-09 00:00` to `2026-04-10 00:00`
- Send UTC:
  - `start_date=2026-04-08T17:00:00Z`
  - `end_date=2026-04-09T17:00:00Z`

## OpenClaw-specific credentials wiring
- Configure skill entry in `openclaw.json` under `skills.entries.news-api-currents`.
- Reference `CURRENTS_API_KEY` under the skill entry's `env` object; do not place the key value in the skill file.
- `skills.entries.*.env` affects host-run context; sandbox env must be configured separately.

## WAF/User-Agent pitfall (learned)
A default script fingerprint can be blocked by upstream Cloudflare/WAF.
Observed failure mode:
- `403`
- Cloudflare `error code: 1010`

Mitigation:
- Do not rely on default Python urllib UA (`Python-urllib/...`).
- Send explicit browser/curl-like `User-Agent` in backend HTTP calls.
- `curl` or `requests` with explicit UA is typically accepted.
- Keep bearer auth unchanged.

## Verification
- [ ] No key in frontend bundle/network payloads.
- [ ] Key loaded from the environment.
- [ ] Validation/rate limiting enabled.
- [ ] Cache hit ratio measurable.
- [ ] 400/401/429/5xx mapped consistently.
- [ ] Backend client sets explicit `User-Agent`.
