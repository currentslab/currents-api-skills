---
name: news-api-currents
description: OpenCode skill for securely proxying Currents API through a backend service.
license: MIT
compatibility: Requires CURRENTS_API_KEY in the runtime environment.
metadata:
  tags: [currents, proxy, backend, security, opencode]
---

# Currents Owner Interface (OpenCode)

## Trigger
Use when a user wants Currents news in an end-user product without exposing the owner API key.

## Requirements
- Backend service with outbound internet access
- Runtime env var: `CURRENTS_API_KEY`

## Need an API key?
If you do not have a Currents API key yet, register here:
- https://currentsapi.services/en/register

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
