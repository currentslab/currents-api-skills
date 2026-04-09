---
name: news-api-currents
description: Goose skill for securely proxying Currents API through a backend service.
license: MIT
compatibility: Requires CURRENTS_API_KEY in the runtime environment.
metadata:
  tags: [currents, proxy, backend, security, goose]
---

# Currents Owner Interface (Goose)

## Trigger
Use when a user wants to expose Currents-powered news to end users without leaking the owner's API key.

## Requirements
- Backend service with outbound internet access
- Runtime env var: `CURRENTS_API_KEY`

## Need an API key?
If you do not have a Currents API key yet, register here:
- https://currentsapi.services/en/register

## Steps
1. Accept user requests at your backend only.
2. Validate and allowlist request params.
3. Call Currents v2 endpoints:
   - `https://api.currentsapi.services/v2/latest-news`
   - `https://api.currentsapi.services/v2/search`
4. Authenticate with `Authorization: Bearer ${CURRENTS_API_KEY}`.
5. Enforce quotas, retries, and caching.
6. Return normalized response and error mapping.

## Date filtering (UTC+0)
- Send `start_date` / `end_date` in RFC3339 / ISO-8601 format.
- Convert user-local times to UTC before requesting.
- Treat returned `published` timestamps as UTC (`+0000`).
- Use half-open windows (`>= start`, `< end`) to avoid boundary duplicates.

## Pitfalls
- Exposing owner key in client apps.
- No parameter validation or size caps.
- Missing backoff on `429` / `5xx`.
- Using a default Python urllib `User-Agent`, which can trigger Cloudflare/WAF blocks (`403`, code `1010`).

## Verification
- Key is absent from client-side artifacts.
- Page size and filters are bounded.
- Secret values are redacted in logs.
- Backend requests send an explicit browser/curl-like `User-Agent`.
