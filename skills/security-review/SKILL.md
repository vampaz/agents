---
name: security-review
description: Ensure code follows web, TypeScript, Vue, and Cloudflare Workers security best practices and identify concrete vulnerabilities.
---

# Security Review

Use this skill when implementing or reviewing authentication, authorization, untrusted input, file uploads, HTML rendering, API endpoints, Cloudflare Workers bindings/secrets, cookies, CORS, or third-party integrations.

For browser security guidance, use the `modern-web-guidance` skill to retrieve the relevant security guide when reviewing DOM injection, CSP, Trusted Types, cookies, cross-origin messaging, or passkeys.

## Security Checklist

### 1. Secrets and Configuration

- Never hardcode API keys, tokens, signing keys, or credentials in source files, tests, or `wrangler.jsonc`.
- Load secrets from environment bindings (`env.SECRET_NAME` in Cloudflare Workers) or secret stores, and fail fast when a required secret is missing.
- Keep `.env*` and `.dev.vars` ignored by git; check the diff for accidental credentials before committing.
- Never log secrets, authorization headers, cookies, session tokens, or full payment/PII payloads.

```typescript
// BAD: leaks credentials into logs and exposes stack traces to clients
console.log('Login attempt', { email, password, authHeader })
return Response.json({ error: err.message, stack: err.stack }, { status: 500 })

// GOOD: log non-sensitive identifiers server-side and return generic errors
console.error('Login failed', { userId, requestId })
return Response.json({ error: 'Internal server error' }, { status: 500 })
```

### 2. Input Validation and Parsing

- Validate all untrusted input (request params, query strings, JSON bodies, headers, webhooks, file uploads) at the boundary with an explicit schema or strict allowlist before using it.
- Enforce size limits on request bodies and uploads; check MIME type, file signature/content, and safe filename handling when accepting files.
- Guard against prototype pollution (`__proto__`, `constructor`, `prototype`) when indexing objects with untrusted keys—prefer `Map` or `Object.create(null)`.

### 3. Injection Prevention (SQL, Command, SSRF, Path Traversal)

- **SQL / D1**: Always use parameterized queries (`env.DB.prepare('SELECT ... WHERE id = ?').bind(id)`). Never interpolate untrusted values into SQL strings.
- **Shell / Subprocess**: Never interpolate untrusted input into shell commands. Pass argument arrays (`execFile`, `spawn` without `shell: true`) and validate paths/names strictly.
- **SSRF**: Validate user-supplied URLs (scheme allowlist `https:`, reject private/loopback/link-local hosts and unexpected redirects) before fetching server-side.
- **Paths**: Canonicalize paths and verify they stay inside the intended root directory before reading or writing.

### 4. Authentication, Authorization, and Sessions

- Verify authentication and object-level authorization (`ownerId === session.userId` or explicit role check) on every mutating or private endpoint—never rely on client-side route guards alone.
- Verify webhook and JWT signatures with constant-time comparison and validate `iss`, `aud`, `exp`, and `alg` explicitly.
- Store session tokens in `HttpOnly; Secure` cookies (not `localStorage`). Match `SameSite` (`Lax` or `Strict`) to the login and embedding flows.

### 5. XSS, Vue Templates, and CSP

- In Vue components, avoid `v-html` on untrusted or user-derived content. When rendering rich HTML is required, sanitize with a maintained sanitizer using an explicit tag/attribute allowlist.
- Never bind unvalidated URLs to `href`, `src`, or `action` without checking for `http:`/`https:` (reject `javascript:` and untrusted `data:` URIs).
- Inspect existing headers, inline scripts, and third-party origins before defining or tightening `Content-Security-Policy`; prefer nonces or hashes over `'unsafe-inline'` and `'unsafe-eval'`.

### 6. CSRF, CORS, and Rate Limiting

- Protect state-changing cookie-authenticated endpoints against CSRF (explicit CSRF token or verified `Origin`/`Sec-Fetch-Site` check); do not assume CORS alone prevents CSRF.
- Never combine `Access-Control-Allow-Credentials: true` with a wildcard or blindly echoed `Origin` header; validate against an explicit allowlist.
- Rate-limit authentication, search, AI inference, and other expensive endpoints (e.g., Cloudflare Rate Limiting rules or Durable Object/Worker limiters).

### 7. Dependencies and Supply Chain

- Check `npm audit` and review transitive dependencies, install scripts, and licenses before adding packages (use the `select-dependencies` skill for new dependencies).
- Commit lockfiles (`package-lock.json` / `pnpm-lock.yaml`) and pin GitHub Actions to full commit SHAs with minimal token permissions.

## Output

Report findings ordered by severity/user impact with exact file/line references, concrete exploit or failure path, and minimal safe remediation. Separate verified issues from assumptions or checks not run.
