---
name: news-api-currents
description: Portable AgentSkills version for securely proxying Currents API through a backend service.
license: MIT
compatibility: Requires CURRENTS_API_KEY in runtime environment.
metadata:
  tags: [currents, proxy, backend, security]
---

# Currents Owner Interface (Portable)

## Trigger
Use when a user asks to expose Currents data to end users while keeping owner credentials private.

## Requirements
- Backend service with outbound internet
- Runtime env var: `CURRENTS_API_KEY`

## Need an API key?
If you do not have a Currents API key yet, register here:
- https://currentsapi.services/en/register

## Steps
1. Accept user request at your backend only.
2. Validate and allowlist request params.
3. Call:
   - `https://api.currentsapi.services/v2/latest-news`
   - `https://api.currentsapi.services/v2/search`
4. Authenticate with a bearer Authorization header sourced from the environment.
5. Enforce request quotas + caching.
6. Return normalized response schema and error mapping.

## Date filtering (UTC+0)
- Send `start_date` / `end_date` in RFC3339/ISO-8601 format.
- Convert user-local times to UTC (`Z`) before requesting.
- Treat returned `published` timestamps as UTC (`+0000`).
- Use half-open windows (`>= start`, `< end`) to avoid boundary duplicates.

## Pitfalls
- Exposing owner key in client apps.
- No param validation.
- Missing retries/backoff on 5xx or 429.
- Using default Python urllib User-Agent can trigger Cloudflare/WAF block (`403`, error `1010`).

## Verification
- Key absent from client-side artifacts.
- Bounded page size and validated filters.
- Audit logs redact secret values.
- Backend requests send explicit browser/curl-like `User-Agent`.
